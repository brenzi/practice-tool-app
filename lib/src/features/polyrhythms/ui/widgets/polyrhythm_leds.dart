import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/polyrhythm_math.dart';
import '../../providers/polyrhythm_providers.dart';

class PolyrhythmLeds extends ConsumerWidget {
  const PolyrhythmLeds({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(polyrhythmProvider.select((s) => s.a));
    final b = ref.watch(polyrhythmProvider.select((s) => s.b));
    final showSub = ref.watch(
      polyrhythmProvider.select((s) => s.showSubdivision),
    );
    final currentA = ref.watch(
      polyrhythmProvider.select((s) => s.currentTickA),
    );
    final currentB = ref.watch(
      polyrhythmProvider.select((s) => s.currentTickB),
    );
    final isPlaying = ref.watch(polyrhythmProvider.select((s) => s.isPlaying));
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - 48; // padding
        const ledRadius = 8.0;

        Widget buildRow({
          required String label,
          required int count,
          required Color activeColor,
          required Color inactiveColor,
          int activeIndex = -1,
        }) {
          final positions = beatPositions(count);
          return SizedBox(
            height: 40,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  top: 12,
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                ...List.generate(count, (i) {
                  final x = 24 + positions[i] * width;
                  final isActive = isPlaying && i == activeIndex;
                  return Positioned(
                    left: x - ledRadius,
                    top: 12,
                    child: Container(
                      width: ledRadius * 2,
                      height: ledRadius * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? activeColor : inactiveColor,
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }

        final subCount = lcm(a, b);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildRow(
                label: 'A',
                count: a,
                activeColor: colorScheme.primary,
                inactiveColor: colorScheme.primaryContainer,
                activeIndex: currentA,
              ),
              const SizedBox(height: 8),
              buildRow(
                label: 'B',
                count: b,
                activeColor: colorScheme.tertiary,
                inactiveColor: colorScheme.tertiaryContainer,
                activeIndex: currentB,
              ),
              if (showSub) ...[
                const SizedBox(height: 8),
                buildRow(
                  label: 's',
                  count: subCount,
                  activeColor: colorScheme.outline,
                  inactiveColor: colorScheme.outlineVariant.withValues(
                    alpha: 0.3,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
