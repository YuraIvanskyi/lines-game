# from src.models.board import Board
import pygame
from src.const.colors import GameColors
from src.models.board import Board, Point


def main():
    board = Board(width=5, height=5, start_anchor=Point(0, 0))
    board.display()
    board.possible_connections()
    # board.connect_cords((0, 0), (1, 1))
    # board.display()
    # board.connect_cords((1, 1), (2, 2))
    # board.display()
    # board.connect_cords((2, 2), (3, 2))
    # board.display()
    # board.connect_cords((3, 2), (3, 3))
    # board.display()
    # board.connect_cords((3, 3), (4, 3))
    # board.display()
    # board.connect_cords((4, 3), (3, 4))
    # board.display()
    # board.connect_cords((3, 4), (4, 4))
    # board.display()
    # board.connect_cords((4, 4), (5, 3))
    # board.display()
    # board.draw_board()
    # board.state()


def pygame_main():
    pygame.init()
    screen = pygame.display.set_mode(display=1, size=(720, 720))
    clock = pygame.time.Clock()
    running = True

    while running:
        # poll for events
        # pygame.QUIT event means the user clicked X to close your window
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

        # fill the screen with a color to wipe away anything from last frame
        screen.fill(GameColors.SCREEN_BG)

        # RENDER YOUR GAME HERE

        # flip() the display to put your work on screen
        pygame.display.flip()

        clock.tick(60)  # limits FPS to 60

    pygame.quit()


if __name__ == "__main__":
    # pygame_main()
    main()
