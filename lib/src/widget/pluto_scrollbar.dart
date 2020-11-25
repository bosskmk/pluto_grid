part of '../../pluto_grid.dart';
/*
 * This widget modifies [CupertinoScrollbar] a little,
 * so that the horizontal and vertical scroll controllers work together.
*/

// All values eyeballed.
const double _kScrollbarMinLength = 36.0;
const double _kScrollbarMinOverscrollLength = 8.0;
const Duration _kScrollbarTimeToFade = Duration(milliseconds: 1200);
const Duration _kScrollbarFadeDuration = Duration(milliseconds: 250);
const Duration _kScrollbarResizeDuration = Duration(milliseconds: 100);

// Extracted from iOS 13.1 beta using Debug View Hierarchy.
const Color _kScrollbarColor = CupertinoDynamicColor.withBrightness(
  color: Color(0x59000000),
  darkColor: Color(0x80FFFFFF),
);

// This is the amount of space from the top of a vertical scrollbar to the
// top edge of the scrollable, measured when the vertical scrollbar overscrolls
// to the top.
// TODO(LongCatIsLooong): fix https://github.com/flutter/flutter/issues/32175
const double _kScrollbarMainAxisMargin = 3.0;
const double _kScrollbarCrossAxisMargin = 3.0;

class PlutoScrollbar extends StatefulWidget {
  const PlutoScrollbar({
    Key key,
    this.horizontalController,
    this.verticalController,
    this.isAlwaysShown = false,
    this.thickness = defaultThickness,
    this.thicknessWhileDragging = defaultThicknessWhileDragging,
    this.radius = defaultRadius,
    this.radiusWhileDragging = defaultRadiusWhileDragging,
    @required this.child,
  })  : assert(thickness != null),
        assert(thickness < double.infinity),
        assert(thicknessWhileDragging != null),
        assert(thicknessWhileDragging < double.infinity),
        assert(radius != null),
        assert(radiusWhileDragging != null),
        assert(!isAlwaysShown ||
            (horizontalController != null || verticalController != null)),
        super(key: key);

  static const double defaultThickness = 3;

  static const double defaultThicknessWhileDragging = 8.0;

  static const Radius defaultRadius = Radius.circular(1.5);

  static const Radius defaultRadiusWhileDragging = Radius.circular(4.0);

  final Widget child;

  final ScrollController horizontalController;

  final ScrollController verticalController;

  final bool isAlwaysShown;

  final double thickness;

  final double thicknessWhileDragging;

  final Radius radius;

  final Radius radiusWhileDragging;

  @override
  _CupertinoScrollbarState createState() => _CupertinoScrollbarState();
}

class _CupertinoScrollbarState extends State<PlutoScrollbar>
    with TickerProviderStateMixin {
  final GlobalKey _customPaintKey = GlobalKey();
  ScrollbarPainter _painter;

  AnimationController _fadeoutAnimationController;
  Animation<double> _fadeoutOpacityAnimation;
  AnimationController _thicknessAnimationController;
  Timer _fadeoutTimer;
  double _dragScrollbarAxisPosition;
  Drag _drag;

  double get _thickness {
    return widget.thickness +
        _thicknessAnimationController.value *
            (widget.thicknessWhileDragging - widget.thickness);
  }

  Radius get _radius {
    return Radius.lerp(widget.radius, widget.radiusWhileDragging,
        _thicknessAnimationController.value);
  }

  ScrollController _currentController;

  ScrollController get _controller {
    if (_currentAxis == null) {
      return widget.verticalController ??
          widget.horizontalController ??
          PrimaryScrollController.of(context);
    }

    return _currentAxis == Axis.vertical
        ? widget.verticalController
        : widget.horizontalController;
  }

  Axis _currentAxis;

  @override
  void initState() {
    super.initState();
    _fadeoutAnimationController = AnimationController(
      vsync: this,
      duration: _kScrollbarFadeDuration,
    );
    _fadeoutOpacityAnimation = CurvedAnimation(
      parent: _fadeoutAnimationController,
      curve: Curves.fastOutSlowIn,
    );
    _thicknessAnimationController = AnimationController(
      vsync: this,
      duration: _kScrollbarResizeDuration,
    );
    _thicknessAnimationController.addListener(() {
      _painter.updateThickness(_thickness, _radius);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_painter == null) {
      _painter = _buildCupertinoScrollbarPainter(context);
    } else {
      _painter
        ..textDirection = Directionality.of(context)
        ..color = CupertinoDynamicColor.resolve(_kScrollbarColor, context)
        ..padding = MediaQuery.of(context).padding;
    }
    _triggerScrollbar();
  }

  @override
  void didUpdateWidget(PlutoScrollbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(_painter != null);
    _painter.updateThickness(_thickness, _radius);
    if (widget.isAlwaysShown != oldWidget.isAlwaysShown) {
      if (widget.isAlwaysShown == true) {
        _triggerScrollbar();
        _fadeoutAnimationController.animateTo(1.0);
      } else {
        _fadeoutAnimationController.reverse();
      }
    }
  }

  /// Returns a [ScrollbarPainter] visually styled like the iOS scrollbar.
  ScrollbarPainter _buildCupertinoScrollbarPainter(BuildContext context) {
    return ScrollbarPainter(
      color: CupertinoDynamicColor.resolve(_kScrollbarColor, context),
      textDirection: Directionality.of(context),
      thickness: _thickness,
      fadeoutOpacityAnimation: _fadeoutOpacityAnimation,
      mainAxisMargin: _kScrollbarMainAxisMargin,
      crossAxisMargin: _kScrollbarCrossAxisMargin,
      radius: _radius,
      padding: MediaQuery.of(context).padding,
      minLength: _kScrollbarMinLength,
      minOverscrollLength: _kScrollbarMinOverscrollLength,
    );
  }

  // Wait one frame and cause an empty scroll event.  This allows the thumb to
  // show immediately when isAlwaysShown is true.  A scroll event is required in
  // order to paint the thumb.
  void _triggerScrollbar() {
    WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
      if (widget.isAlwaysShown) {
        _fadeoutTimer?.cancel();
        if (widget.verticalController.hasClients) {
          widget.verticalController.position.didUpdateScrollPositionBy(0);
        }
      }
    });
  }

  // Handle a gesture that drags the scrollbar by the given amount.
  void _dragScrollbar(double primaryDelta) {
    assert(_currentController != null);

    // Convert primaryDelta, the amount that the scrollbar moved since the last
    // time _dragScrollbar was called, into the coordinate space of the scroll
    // position, and create/update the drag event with that position.
    final double scrollOffsetLocal = _painter.getTrackToScroll(primaryDelta);
    final double scrollOffsetGlobal =
        scrollOffsetLocal + _currentController.position.pixels;
    final Axis direction = _currentController.position.axis;

    if (_drag == null) {
      _drag = _currentController.position.drag(
        DragStartDetails(
          globalPosition: direction == Axis.vertical
              ? Offset(0.0, scrollOffsetGlobal)
              : Offset(scrollOffsetGlobal, 0.0),
        ),
        () {},
      );
    } else {
      _drag.update(DragUpdateDetails(
        globalPosition: direction == Axis.vertical
            ? Offset(0.0, scrollOffsetGlobal)
            : Offset(scrollOffsetGlobal, 0.0),
        delta: direction == Axis.vertical
            ? Offset(0.0, -scrollOffsetLocal)
            : Offset(-scrollOffsetLocal, 0.0),
        primaryDelta: -scrollOffsetLocal,
      ));
    }
  }

  void _startFadeoutTimer() {
    if (!widget.isAlwaysShown) {
      _fadeoutTimer?.cancel();
      _fadeoutTimer = Timer(_kScrollbarTimeToFade, () {
        _fadeoutAnimationController.reverse();
        _fadeoutTimer = null;
      });
    }
  }

  Axis _getDirection() {
    try {
      return _currentController.position.axis;
    } catch (_) {
      // Ignore the gesture if we cannot determine the direction.
      return null;
    }
  }

  double _pressStartAxisPosition = 0.0;

  // Long press event callbacks handle the gesture where the user long presses
  // on the scrollbar thumb and then drags the scrollbar without releasing.
  void _handleLongPressStart(LongPressStartDetails details) {
    _currentController = _controller;
    final Axis direction = _getDirection();
    if (direction == null) {
      return;
    }
    _fadeoutTimer?.cancel();
    _fadeoutAnimationController.forward();
    switch (direction) {
      case Axis.vertical:
        _pressStartAxisPosition = details.localPosition.dy;
        _dragScrollbar(details.localPosition.dy);
        _dragScrollbarAxisPosition = details.localPosition.dy;
        break;
      case Axis.horizontal:
        _pressStartAxisPosition = details.localPosition.dx;
        _dragScrollbar(details.localPosition.dx);
        _dragScrollbarAxisPosition = details.localPosition.dx;
        break;
    }
  }

  void _handleLongPress() {
    if (_getDirection() == null) {
      return;
    }
    _fadeoutTimer?.cancel();
    _thicknessAnimationController.forward().then<void>(
          (_) => HapticFeedback.mediumImpact(),
        );
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    final Axis direction = _getDirection();
    if (direction == null) {
      return;
    }
    switch (direction) {
      case Axis.vertical:
        _dragScrollbar(details.localPosition.dy - _dragScrollbarAxisPosition);
        _dragScrollbarAxisPosition = details.localPosition.dy;
        break;
      case Axis.horizontal:
        _dragScrollbar(details.localPosition.dx - _dragScrollbarAxisPosition);
        _dragScrollbarAxisPosition = details.localPosition.dx;
        break;
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    final Axis direction = _getDirection();
    if (direction == null) {
      return;
    }
    switch (direction) {
      case Axis.vertical:
        _handleDragScrollEnd(details.velocity.pixelsPerSecond.dy, direction);
        if (details.velocity.pixelsPerSecond.dy.abs() < 10 &&
            (details.localPosition.dy - _pressStartAxisPosition).abs() > 0) {
          HapticFeedback.mediumImpact();
        }
        break;
      case Axis.horizontal:
        _handleDragScrollEnd(details.velocity.pixelsPerSecond.dx, direction);
        if (details.velocity.pixelsPerSecond.dx.abs() < 10 &&
            (details.localPosition.dx - _pressStartAxisPosition).abs() > 0) {
          HapticFeedback.mediumImpact();
        }
        break;
    }
    _currentController = null;
  }

  void _handleDragScrollEnd(double trackVelocity, Axis direction) {
    _startFadeoutTimer();
    _thicknessAnimationController.reverse();
    _dragScrollbarAxisPosition = null;
    final double scrollVelocity = _painter.getTrackToScroll(trackVelocity);
    _drag?.end(DragEndDetails(
      primaryVelocity: -scrollVelocity,
      velocity: Velocity(
        pixelsPerSecond: direction == Axis.vertical
            ? Offset(0.0, -scrollVelocity)
            : Offset(-scrollVelocity, 0.0),
      ),
    ));
    _drag = null;
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    final ScrollMetrics metrics = notification.metrics;
    if (metrics.maxScrollExtent <= metrics.minScrollExtent) {
      return false;
    }

    _currentAxis = axisDirectionToAxis(metrics.axisDirection);

    if (notification is ScrollUpdateNotification ||
        notification is UserScrollNotification ||
        notification is OverscrollNotification) {
      // Any movements always makes the scrollbar start showing up.
      if (_fadeoutAnimationController.status != AnimationStatus.forward) {
        _fadeoutAnimationController.forward();
      }

      _fadeoutTimer?.cancel();
      _painter.update(metrics, metrics.axisDirection);
    } else if (notification is ScrollEndNotification) {
      // On iOS, the scrollbar can only go away once the user lifted the finger.
      if (_dragScrollbarAxisPosition == null) {
        _startFadeoutTimer();
      }
    }
    return false;
  }

  // Get the GestureRecognizerFactories used to detect gestures on the scrollbar
  // thumb.
  Map<Type, GestureRecognizerFactory> get _gestures {
    final Map<Type, GestureRecognizerFactory> gestures =
        <Type, GestureRecognizerFactory>{};

    gestures[_ThumbPressGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<_ThumbPressGestureRecognizer>(
      () => _ThumbPressGestureRecognizer(
        debugOwner: this,
        customPaintKey: _customPaintKey,
      ),
      (_ThumbPressGestureRecognizer instance) {
        instance
          ..onLongPressStart = _handleLongPressStart
          ..onLongPress = _handleLongPress
          ..onLongPressMoveUpdate = _handleLongPressMoveUpdate
          ..onLongPressEnd = _handleLongPressEnd;
      },
    );

    return gestures;
  }

  @override
  void dispose() {
    _fadeoutAnimationController.dispose();
    _thicknessAnimationController.dispose();
    _fadeoutTimer?.cancel();
    _painter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: RepaintBoundary(
        child: RawGestureDetector(
          gestures: _gestures,
          child: CustomPaint(
            key: _customPaintKey,
            foregroundPainter: _painter,
            child: RepaintBoundary(child: widget.child),
          ),
        ),
      ),
    );
  }
}

// A longpress gesture detector that only responds to events on the scrollbar's
// thumb and ignores everything else.
class _ThumbPressGestureRecognizer extends LongPressGestureRecognizer {
  _ThumbPressGestureRecognizer({
    double postAcceptSlopTolerance,
    PointerDeviceKind kind,
    @required Object debugOwner,
    @required GlobalKey customPaintKey,
  })  : _customPaintKey = customPaintKey,
        super(
          postAcceptSlopTolerance: postAcceptSlopTolerance,
          kind: kind,
          debugOwner: debugOwner,
          duration: const Duration(milliseconds: 100),
        );

  final GlobalKey _customPaintKey;

  @override
  bool isPointerAllowed(PointerDownEvent event) {
    if (!_hitTestInteractive(_customPaintKey, event.position)) {
      return false;
    }
    return super.isPointerAllowed(event);
  }
}

// foregroundPainter also hit tests its children by default, but the
// scrollbar should only respond to a gesture directly on its thumb, so
// manually check for a hit on the thumb here.
bool _hitTestInteractive(GlobalKey customPaintKey, Offset offset) {
  if (customPaintKey.currentContext == null) {
    return false;
  }
  final CustomPaint customPaint =
      customPaintKey.currentContext.widget as CustomPaint;
  final ScrollbarPainter painter =
      customPaint.foregroundPainter as ScrollbarPainter;
  final RenderBox renderBox =
      customPaintKey.currentContext.findRenderObject() as RenderBox;
  final Offset localOffset = renderBox.globalToLocal(offset);
  return painter.hitTestInteractive(localOffset);
}
