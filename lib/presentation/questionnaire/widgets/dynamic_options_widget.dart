import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants.dart';
import '../../../core/design/components/ui_button.dart';
import '../../../core/design/content/app_strings.dart';
import '../../../core/design/tokens/sizes.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/di/injection.dart';
import '../../../core/failures.dart';
import '../../../domain/entities/option.dart';
import '../../../domain/usecases/get_dynamic_options.dart';
import 'option_tile.dart';

/// Виджет с поисковым полем и подгружаемым списком опций. Локальный
/// `ValueNotifier` хранит загруженные варианты — отдельный Cubit избыточен
/// для одной операции (как в архитектурном документе раздел DynamicOptionsWidget).
class DynamicOptionsWidget extends StatefulWidget {
  const DynamicOptionsWidget({
    super.key,
    required this.userId,
    required this.questionId,
    required this.selected,
    required this.onSelect,
    this.enabled = true,
  });

  final int userId;
  final int questionId;
  final DynamicOption? selected;
  final ValueChanged<DynamicOption> onSelect;
  final bool enabled;

  @override
  State<DynamicOptionsWidget> createState() => _DynamicOptionsWidgetState();
}

class _DynamicOptionsWidgetState extends State<DynamicOptionsWidget> {
  late final TextEditingController _controller;
  final ValueNotifier<_OptionsState> _state = ValueNotifier<_OptionsState>(
    const _OptionsState.idle(),
  );
  Timer? _debounce;
  GetDynamicOptions get _useCase => sl<GetDynamicOptions>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _load(null);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _state.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(kSearchDebounce, () => _load(value));
  }

  Future<void> _load(String? query) async {
    _state.value = const _OptionsState.loading();
    try {
      final items = await _useCase(
        userId: widget.userId,
        questionId: widget.questionId,
        query: query,
      );
      if (!mounted) return;
      _state.value = _OptionsState.loaded(items);
    } on AppFailure catch (f) {
      if (!mounted) return;
      _state.value = _OptionsState.error(f);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          onChanged: widget.enabled ? _onSearch : null,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: AppStrings.questionnaire.searchHint,
            prefixIcon: const Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ValueListenableBuilder<_OptionsState>(
          valueListenable: _state,
          builder:
              (context, state, _) => state.when(
                idle: () => const SizedBox.shrink(),
                loading:
                    () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                      child: Center(
                        child: SizedBox(
                          width: AppControlSize.selector,
                          height: AppControlSize.selector,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                loaded:
                    (items) =>
                        items.isEmpty
                            ? Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.xxl,
                              ),
                              child: Center(
                                child: Text(
                                  AppStrings.questionnaire.searchEmpty,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            )
                            : Column(
                              children: List.generate(items.length, (i) {
                                final option = items[i];
                                final isSelected =
                                    selected?.code == option.code;
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.md,
                                  ),
                                  child: _OptionRow(
                                    label: option.label,
                                    selected: isSelected,
                                    onTap: () => widget.onSelect(option),
                                  ),
                                );
                              }),
                            ),
                error:
                    (f) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.lg,
                      ),
                      child: Center(
                        child: UiButton(
                          label: AppStrings.common.retry,
                          onPressed: () => _load(_controller.text),
                          variant: UiButtonVariant.text,
                          icon: Icons.refresh_rounded,
                        ),
                      ),
                    ),
              ),
        ),
      ],
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OptionTile(
      label: label,
      selected: selected,
      onTap: onTap,
      trailing: OptionCheck(selected: selected),
    );
  }
}

class _OptionsState {
  const _OptionsState._({required this.status, this.items, this.failure});

  const _OptionsState.idle() : this._(status: _Status.idle);
  const _OptionsState.loading() : this._(status: _Status.loading);
  const _OptionsState.loaded(List<DynamicOption> items)
    : this._(status: _Status.loaded, items: items);
  const _OptionsState.error(AppFailure failure)
    : this._(status: _Status.error, failure: failure);

  final _Status status;
  final List<DynamicOption>? items;
  final AppFailure? failure;

  T when<T>({
    required T Function() idle,
    required T Function() loading,
    required T Function(List<DynamicOption> items) loaded,
    required T Function(AppFailure failure) error,
  }) {
    switch (status) {
      case _Status.idle:
        return idle();
      case _Status.loading:
        return loading();
      case _Status.loaded:
        return loaded(items ?? const []);
      case _Status.error:
        return error(failure!);
    }
  }
}

enum _Status { idle, loading, loaded, error }
