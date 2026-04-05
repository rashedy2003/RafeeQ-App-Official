abstract class NavigationState {}

class NavigationInitial extends NavigationState {
  final int index;
  NavigationInitial(this.index);
}