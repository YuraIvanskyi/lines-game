import pygame
import pygame.freetype
import pygame_menu
from src.models.ui.action_phase import VisualBoard
from pygame_menu import themes


class Game:
    DIMX = 500
    DIMY = 600

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
        self.board = VisualBoard(10, 10, self.surface)
        # self.board.random_simulation()

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
                self.font.render_to(self.surface, (10, 10), "You lost, no connections left")
            else:
                self.font.render_to(self.surface, (10, 10), "Possible moves:")
            if event.type == pygame.QUIT:
                exit()
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_SPACE:
                    self.board = self.board.flush()
                    self.surface.fill((255, 255, 255))
                    pygame.display.flip()
                else:
                    next_connection = self.board.pick_next(event.key)
                    if next_connection:
                        self.board.connect_head(next_connection)

            self.board.draw()

            for i, chunk in enumerate(
                [
                    self.board.possible_connections()[i : i + 3]
                    for i in range(0, len(self.board.possible_connections()), 3)
                ],
                1,
            ):
                self.font.render_to(self.surface, (10, 15 + 15 * i), f"{chunk}")

            # if self.mainmenu.is_enabled() and not self.is_ap:
            #     self.mainmenu.draw(self.surface)
            #     self.mainmenu.update(events)

            # if self.action_phase.is_enabled() and self.is_ap:
            #     self.action_phase.draw(self.surface)
            #     self.action_phase.update(events)

            pygame.display.flip()
