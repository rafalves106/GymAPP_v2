import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class WorkShell extends StatelessWidget {
  final Widget child;
  const WorkShell({super.key, this.child = const SizedBox.shrink()});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home/profile')) return 2;
    if (location.startsWith('/home/work/trainings')) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/home/work/exercises');
            case 1:
              context.go('/home/work/trainings');
            case 2:
              context.go('/home/profile');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(CupertinoIcons.sportscourt),
            label: 'Exercises',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.calendar),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
