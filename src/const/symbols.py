class BoardSymbol:
    class Node:
        EMPTY = "◯"
        FILLED = "⦿"
        H_GREEN = "💚"
        H_RED = "❤️️"

    class Connection:
        TOP = "⬆"
        BOTTOM = "⬇"
        LEFT = "⬅"
        RIGHT = "➡"
        TOP_LEFT = "⬈"
        TOP_RIGHT = "⬉"
        BOTTOM_LEFT = "⬊"
        BOTTOM_RIGHT = "⬋"

        VERTICAL = "│"
        HORIZONTAL = "━━"
        MISSING = "⌗"
        DIAG_LT_RB = "╲"
        DIAG_RB_LT = "╱"

        DEGREE_MAP = {
            DIAG_LT_RB: -45,
            DIAG_RB_LT: -135,
            VERTICAL: -90,
            HORIZONTAL: 0,
            MISSING: 0,
        }
