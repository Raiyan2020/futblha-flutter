import 'package:flutter/material.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import '../../application/core/utils/helpers/debouncer.dart';
import 'custom_loading_widget.dart';

class PaginationList extends StatefulWidget {
  final Function()? onReachBottom;
  final bool reachedMax;
  final int itemCount;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollController? scrollController;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget? separator;
  final bool gridView;
  final bool horizontal;
  final bool animateItems;

  const PaginationList({
    super.key,
    required this.itemCount,
    this.onReachBottom,
    this.padding,
    this.scrollController,
    this.shrinkWrap = false,
    this.reachedMax = false,
    this.gridView = false,
    this.horizontal = false,
    required this.itemBuilder,
    this.separator,
    this.animateItems = false,
  });

  @override
  State<PaginationList> createState() => _PaginationListState();
}

class _PaginationListState extends State<PaginationList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(debounce(_onScroll, 300));
  }

  void _onScroll() async {
    if (_isBottom && !widget.reachedMax) {
      if (widget.onReachBottom != null) widget.onReachBottom!();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.70);
  }

  @override
  Widget build(BuildContext context) {
    int length = widget.reachedMax == true ? 0 : 1;
    if (!widget.gridView) {
      return ListView.separated(
        scrollDirection: widget.horizontal ? Axis.horizontal : Axis.vertical,
        itemCount: widget.itemCount + length,
        controller: widget.scrollController != null ? null : _scrollController,
        physics: widget.scrollController != null
            ? const NeverScrollableScrollPhysics()
            : const AlwaysScrollableScrollPhysics(),
        shrinkWrap: widget.shrinkWrap,
        padding: widget.padding ?? const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 20),
        separatorBuilder: (_, i) => widget.separator ?? 10.heightBox(),
        itemBuilder: (context, index) {
          if (index == widget.itemCount) {
            return const Center(
              child: LoadingWidget(),
            );
          }
          return widget.animateItems
              ? AnimatedItemBuilder(
                  index: index, itemCount: widget.itemCount, child: widget.itemBuilder(context, index))
              : widget.itemBuilder(context, index);
        },
      );
    } else {
      return GridView.builder(
        itemCount: widget.itemCount + length,
        controller: widget.scrollController != null ? null : _scrollController,
        physics: widget.scrollController != null ? const NeverScrollableScrollPhysics() : null,
        shrinkWrap: widget.shrinkWrap,
        padding: widget.padding ?? const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 15,
          crossAxisSpacing: 10,
          childAspectRatio: 3 / 3,
          crossAxisCount: 2,
        ),
        itemBuilder: (context, index) {
          if (index == widget.itemCount) {
            return const Center(
              child: LoadingWidget(),
            );
          }
          return widget.animateItems
              ? AnimatedItemBuilder(
                  index: index, itemCount: widget.itemCount, child: widget.itemBuilder(context, index))
              : widget.itemBuilder(context, index);
        },
      );
    }
  }
}

// Define a new widget to handle the animation
class AnimatedItemBuilder extends StatelessWidget {
  final int index;
  final int itemCount;
  final Widget child;

  const AnimatedItemBuilder({
    super.key,
    required this.index,
    required this.child,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    final int maxIndex = index < 8 ? index : 5;
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 * maxIndex), // Delay based on item index
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)), // Adjust the vertical offset
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
