import 'package:flutter/material.dart';

class BreedDetailsData {
  final String breedName;
  final String subtitle;
  final int matchPercent;
  final String imageAsset;
  final List<String> reasons;
  final List<BreedStat> stats;
  final String careDescription;

  const BreedDetailsData({
    required this.breedName,
    required this.subtitle,
    required this.matchPercent,
    required this.imageAsset,
    required this.reasons,
    required this.stats,
    required this.careDescription,
  });
}

class BreedStat {
  final IconData icon;
  final String label;
  final String value;

  const BreedStat({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class BreedDetailsScreen extends StatelessWidget {
  const BreedDetailsScreen({
    super.key,
    this.data = const BreedDetailsData(
      breedName: 'Испанский дилдо вПопянЗалупянГандонян',
      subtitle: 'Ваш идеальный компаньон',
      matchPercent: 98,
      imageAsset: 'assets/images/dog_bg.png',
      reasons: [
        'Спокойный и преданный характер',
        'Легко обучается и адаптируется',
        'Отлично ладит с вашей активностью',
      ],
      stats: [
        BreedStat(
          icon: Icons.shield_outlined,
          label: 'Размер',
          value: 'Средний',
        ),
        BreedStat(
          icon: Icons.flash_on_outlined,
          label: 'Энергия',
          value: 'Высокая',
        ),
        BreedStat(
          icon: Icons.favorite_border,
          label: 'Дружелюбие',
          value: 'Высокое',
        ),
        BreedStat(
          icon: Icons.psychology_outlined,
          label: 'Интеллект',
          value: 'Высокий',
        ),
      ],
      careDescription:
          'Корейский джиндо неприхотлив в уходе. Регулярные прогулки, сбалансированное питание и внимание — всё, что нужно для его счастья.',
    ),
  });

  final BreedDetailsData data;

  static const brand = Color(0xFF7C5DFF);
  static const bg = Color(0xFFF8F9FF);
  static const title = Color(0xFF11152B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Header(),
                  const SizedBox(height: 28),
                  _Hero(data: data),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _ReasonCard(reasons: data.reasons),
                        const SizedBox(height: 16),
                        _CharacteristicsCard(stats: data.stats),
                        const SizedBox(height: 16),
                        _CareCard(description: data.careDescription),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const _BottomButton(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: BreedDetailsScreen.brand,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'PET MATCH AI',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: BreedDetailsScreen.brand,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'RU',
            style: TextStyle(
              color: BreedDetailsScreen.brand,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down,
            color: BreedDetailsScreen.brand,
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.data,
  });

  final BreedDetailsData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isSmall = screenWidth < 380;

        final titleLength = data.breedName.length;

        final titleFontSize = titleLength > 42
            ? 26.0
            : titleLength > 30
                ? 30.0
                : titleLength > 20
                    ? 34.0
                    : isSmall
                        ? 36.0
                        : 40.0;

        final heroHeight = titleLength > 42 ? 410.0 : 385.0;
        final imageHeight = isSmall ? 255.0 : 275.0;
        final percentFontSize = isSmall ? 36.0 : 40.0;

        return SizedBox(
          height: heroHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -72,
                top: 48,
                child: Container(
                  width: 292,
                  height: 292,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFF1EFFF),
                        Color(0xFFE1E7FF),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -14,
                top: 86,
                child: Image.asset(
                  data.imageAsset,
                  height: imageHeight,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                left: 24,
                top: 0,
                right: screenWidth * 0.35,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.breedName,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: TextStyle(
                        color: BreedDetailsScreen.title,
                        fontSize: titleFontSize,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 15,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${data.matchPercent}%',
                              style: TextStyle(
                                color: BreedDetailsScreen.brand,
                                fontSize: percentFontSize,
                                height: 1,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite_border,
                            size: 21,
                            color: BreedDetailsScreen.brand,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Отличное\nсовпадение',
                      maxLines: 2,
                      style: TextStyle(
                        color: BreedDetailsScreen.title,
                        fontSize: 15,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReasonCard extends StatelessWidget {
  const _ReasonCard({
    required this.reasons,
  });

  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Почему подходит вам'),
          const SizedBox(height: 18),
          ...reasons.map((reason) => _CheckRow(reason)),
        ],
      ),
    );
  }
}

class _CharacteristicsCard extends StatelessWidget {
  const _CharacteristicsCard({
    required this.stats,
  });

  final List<BreedStat> stats;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: _CardTitle('Характеристики породы'),
              ),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 24) / 2;

              return Wrap(
                runSpacing: 22,
                spacing: 24,
                children: stats
                    .map(
                      (stat) => SizedBox(
                        width: itemWidth,
                        child: _StatItem(stat: stat),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CareCard extends StatelessWidget {
  const _CareCard({
    required this.description,
  });

  final String description;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFF1EFFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: BreedDetailsScreen.brand.withValues(alpha: 0.15),
              ),
            ),
            child: const Icon(
              Icons.pets,
              color: BreedDetailsScreen.brand,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CardTitle('Об уходе'),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF5E6472),
                    fontSize: 15,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: BreedDetailsScreen.title,
        fontSize: 18,
        height: 1.2,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: BreedDetailsScreen.brand,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 17,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF5E6472),
                fontSize: 15,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.stat,
  });

  final BreedStat stat;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          stat.icon,
          color: BreedDetailsScreen.brand,
          size: 28,
        ),
        const SizedBox(height: 10),
        Text(
          stat.label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          stat.value,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: BreedDetailsScreen.title,
            fontSize: 13,
            height: 1.15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _BottomButton extends StatelessWidget {
  const _BottomButton();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Container(
        padding: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: BreedDetailsScreen.bg.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24),
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: BreedDetailsScreen.brand,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size.fromHeight(58),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Подробнее о породе',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
