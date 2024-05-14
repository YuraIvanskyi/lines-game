import pygame
import pygame.freetype
import pygame_menu
from src.const.colors import GameColors
from src.logic.core.board import Board
from pygame_menu import themes

from src.logic.core.utils import PlayerVisual
from src.logic.core.utils import Point


class Game:
    DIMX = 1000
    DIMY = 800

    def __init__(self):
        pygame.init()
        pygame.font.init()
        pygame.display.set_caption("Litterally Pen Game")

        self.surface = pygame.display.set_mode((self.DIMX, self.DIMY))

        self.mainmenu = pygame_menu.Menu("Litterally Pen Game", self.DIMX, self.DIMY, theme=themes.THEME_BLUE)
        self.action_phase = pygame_menu.Menu("Action Phase", self.DIMX, self.DIMY, theme=themes.THEME_BLUE)

        self.font = pygame.freetype.SysFont("FantasqueSansM Nerd Font Propo", 15)
        self.is_ap = False
        self.clock = pygame.time.Clock()
        self.buld_main_menu()
        self.build_action_phase()
        self.board = Board(
            height=25,
            width=25,
            start_anchor=Point(4, 4),
            surface=self.surface,
            players=[
                PlayerVisual(name="Shuri", connection_color=GameColors.DARK_GREEN),
                PlayerVisual(name="Steve", connection_color=GameColors.ORANGE),
                PlayerVisual(name="Chen", connection_color=GameColors.BURGUNDY),
            ],
        )
        self.player_controller = None

    def buld_main_menu(self):
        # self.mainmenu.add.text_input("Name: ", default="username", maxchar=20)
        self.mainmenu.add.button("Play", self.go_to_action_phase)
        self.mainmenu.add.button("Quit", pygame_menu.events.EXIT)

    def build_action_phase(self):
        # self.action_phase.add.image("assets/nbgrid.jpg")
        self.action_phase.add.button("Back", self.back_to_main_menu)
        # self.action_phase_surface = pygame.Surface((300, 300))
        # self.action_phase.add.surface(self.action_phase_surface, "ap_surface")
        # self.action_phase_surface.blit(pygame.image.load("assets/nbgrid.jpg"), (0, 0))

    def go_to_action_phase(self):
        self.mainmenu._open(self.action_phase)
        self.is_ap = True

    def back_to_main_menu(self):
        self.is_ap = False
        self.action_phase.close()

    def mainloop(self):
        self.clock.tick(60)
        # self.surface.blit(pygame.image.load("assets/grid.jpg"), (0, 0))

        while True:
            self.surface.fill((255, 255, 255))
            event = pygame.event.wait()
            if not self.board.possible_connections():
                self.font.render_to(
                    self.surface, (10, 10), f"You lost {self.board.current_player}, no connections left"
                )
            else:
                self.font.render_to(self.surface, (10, 10), f"{self.board.current_player}'s turn")
            if event.type == pygame.QUIT:
                exit()
            if event.type == pygame.MOUSEBUTTONDOWN:
                next_connection = self.board.pick_next_by_mouse(pygame.mouse.get_pos())
                if next_connection and next_connection.from_head:
                    self.board.connect_head(next_connection)
                elif next_connection and next_connection.from_tail:
                    self.board.connect_tail(next_connection)

            if event.type == pygame.MOUSEBUTTONUP:
                self.board.pick_next_by_mouse(pygame.mouse.get_pos())
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_SPACE:
                    self.board = self.board.flush()
                    self.surface.fill((255, 255, 255))
                    pygame.display.flip()
                if event.key == pygame.K_0:
                    self.board.random_simulation()

            self.board.draw()

            # for i, chunk in enumerate(
            #     [self.board.avaialable_moves()[i : i + 8] for i in range(0, len(self.board.avaialable_moves()), 8)],
            #     1,
            # ):
            #     self.font.render_to(self.surface, (10, 15 + 15 * i), f"{chunk}")

            # if self.mainmenu.is_enabled() and not self.is_ap:
            #     self.mainmenu.draw(self.surface)
            #     self.mainmenu.update(events)

            # if self.action_phase.is_enabled() and self.is_ap:
            #     self.action_phase.draw(self.surface)
            #     self.action_phase.update(events)

            pygame.display.flip()
