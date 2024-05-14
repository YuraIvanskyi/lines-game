# from src.models.board import Board
from src.logic.core.board import Board
from src.logic.core.utils import Point
from src.logic.ui.menus import Game


def main():
    board = Board(width=3, height=3, start_anchor=Point(0, 0))
    board.display_as_text()
    board.possible_connections()


def pygame_main():
    game = Game()
    game.mainloop()


if __name__ == "__main__":
    pygame_main()
    # main()
