import 'package:flutter/material.dart';
import 'package:game_2048/model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '2048 game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(
        body: BoardWidget(row: 4, column: 4, someOtherArg: 0),
      ),
    );
  }
}

class BoardWidget extends StatefulWidget {
  final int row;
  final int column;
  final int someOtherArg;

  const BoardWidget(
      {Key? key,
      required this.row,
      required this.column,
      required this.someOtherArg})
      : super(key: key);

  @override
  State<BoardWidget> createState() => BoardWidgetState();
}

class BoardWidgetState extends State<BoardWidget> {
  late Board board;
  bool isMoving = false;
  bool gameover = false;
  final double tilePadding = 8.0;
  final Map<int, Color> tileColors = {
    2: Colors.blue,
    4: Colors.red,
    8: Colors.green,
  };

  @override
  void initState() {
    super.initState();
    board = Board(widget.row, widget.column, widget.someOtherArg);
    newGame();
  }

  void newGame() {
    setState(() {
      board = Board(widget.row, widget.column, widget.someOtherArg);
      isMoving = false;
      gameover = false;
    });
  }

  Size boardSize() {
    return MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    List<TileWidget> tileWidgets = [];
    for (int r = 0; r < widget.row; r++) {
      for (int c = 0; c < widget.column; c++) {
        try {
          Tile tile = board.getTile(r, c);
          tileWidgets.add(TileWidget(tile: tile, state: this));
        } catch (e) {
          print('Error accessing tile at ($r, $c): $e');
        }
      }
    }

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              color: Colors.orange,
              width: 120,
              height: 60,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("score"),
                    Text(board.score
                        .toString()), // Corrected to display actual score
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => newGame(),
              child: Container(
                color: Colors.orange,
                width: 120,
                height: 60,
                child: const Center(
                  child: Text(
                    "New Game",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
        Container(
          height: 16,
        ),
        GestureDetector(
          onVerticalDragEnd: (details) {
            print(
                'Vertical drag ended with velocity: ${details.primaryVelocity}');
            if (details.primaryVelocity! < 0) {
              setState(() {
                board.moveUp();
              });
            } else if (details.primaryVelocity! > 0) {
              setState(() {
                board.moveDown();
              });
            }
          },
          onHorizontalDragEnd: (details) {
            print(
                'Horizontal drag ended with velocity: ${details.primaryVelocity}');
            if (details.primaryVelocity! < 0) {
              setState(() {
                board.moveLeft();
              });
            } else if (details.primaryVelocity! > 0) {
              setState(() {
                board.moveRight();
              });
            }
          },
          child: Container(
            width: boardSize().width,
            height: boardSize().width,
            padding: EdgeInsets.all(tilePadding),
            color: Colors.grey,
            child: Stack(children: tileWidgets),
          ),
        ),
      ],
    );
  }
}

class TileWidget extends StatefulWidget {
  final Tile tile;
  final BoardWidgetState state;

  const TileWidget({Key? key, required this.tile, required this.state})
      : super(key: key);

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
    widget.tile.isNew = false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tile.isNew && widget.tile.isEmpty()) {
      controller.reset();
      controller.forward();
      widget.tile.isNew = false;
    } else {
      controller.animateTo(1.0);
    }
    return AnimatedTileWidget(
      tile: widget.tile,
      state: widget.state,
      animation: animation,
    );
  }
}

class AnimatedTileWidget extends AnimatedWidget {
  final Tile tile;
  final BoardWidgetState state;

  const AnimatedTileWidget({
    Key? key,
    required this.tile,
    required this.state,
    required Animation<double> animation,
  }) : super(listenable: animation, key: key);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;
    double animationValue = animation.value;
    Size boardSize = state.boardSize();
    double widgetSize =
        (boardSize.width - (state.widget.column + 1) * state.tilePadding) /
            state.widget.column;

    if (tile.value == 0) {
      return Container();
    }
    double width = widgetSize;

    return TileBox(
      left: (tile.column * width + state.tilePadding * (tile.column + 1)) +
          width / 2 * (1 - animationValue),
      top: tile.row * width +
          state.tilePadding * (tile.row + 1) +
          width / 2 * (1 - animationValue),
      size: width * animationValue,
      color: state.tileColors.containsKey(tile.value)
          ? state.tileColors[tile.value]!
          : Colors.orange,
      text: '${tile.value}',
    );
  }
}

class TileBox extends StatelessWidget {
  final double left;
  final double top;
  final double size;
  final Color color;
  final String text;

  const TileBox({
    Key? key,
    required this.left,
    required this.top,
    required this.size,
    required this.color,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
        ),
        child: Center(
          child: Text(text),
        ),
      ),
    );
  }
}
