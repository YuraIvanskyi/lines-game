# from src.models.board import Board
import pygame
import pygame_menu
from pygame_menu import themes
from src.const.colors import GameColors
from src.models.core.board import Board, Point
from src.models.ui.menus import Game


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
