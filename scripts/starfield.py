#!/usr/bin/env python3
"""Terminal warp-speed starfield screensaver."""

import curses
import random
import math
import time
import signal
import sys


class Star:
    __slots__ = ("x", "y", "z", "pz", "speed")

    def __init__(self, width, height, depth):
        self.x = random.uniform(-width, width)
        self.y = random.uniform(-height, height)
        self.z = random.uniform(1, depth)
        self.pz = self.z
        self.speed = random.uniform(0.6, 1.4)


def main(stdscr):
    curses.curs_set(0)
    stdscr.nodelay(True)
    stdscr.timeout(30)

    if curses.has_colors():
        curses.start_color()
        curses.use_default_colors()
        curses.init_pair(1, curses.COLOR_WHITE, -1)
        curses.init_pair(2, curses.COLOR_CYAN, -1)
        curses.init_pair(3, curses.COLOR_BLUE, -1)
        curses.init_pair(4, curses.COLOR_MAGENTA, -1)
        curses.init_pair(5, curses.COLOR_YELLOW, -1)
        curses.init_pair(6, 8, -1)  # dark gray for hull

    NUM_STARS = 300
    DEPTH = 64
    WARP_SPEED = 0.05
    STREAK_MULTIPLIER = 3.0

    height, width = stdscr.getmaxyx()
    cx, cy = width // 2, height // 2

    stars = [Star(width, height, DEPTH) for _ in range(NUM_STARS)]

    glyphs_by_depth = [
        (".", curses.A_DIM),
        (".", curses.A_NORMAL),
        ("+", curses.A_NORMAL),
        ("*", curses.A_BOLD),
        ("*", curses.A_BOLD),
    ]

    frame = 0
    t_start = time.monotonic()

    while True:
        key = stdscr.getch()
        if key in (ord("q"), ord("Q"), 27):
            break

        try:
            new_h, new_w = stdscr.getmaxyx()
            if new_h != height or new_w != width:
                height, width = new_h, new_w
                cx, cy = width // 2, height // 2
        except curses.error:
            pass

        stdscr.erase()
        frame += 1
        t = time.monotonic() - t_start

        drift_x = math.sin(t * 0.3) * 0.4
        drift_y = math.cos(t * 0.25) * 0.2

        for star in stars:
            star.pz = star.z
            star.z -= WARP_SPEED * star.speed

            if star.z <= 0.1:
                star.x = random.uniform(-width, width)
                star.y = random.uniform(-height, height)
                star.z = DEPTH
                star.pz = DEPTH
                star.speed = random.uniform(0.6, 1.4)
                continue

            sx = int((star.x + drift_x) / star.z * cx + cx)
            sy = int((star.y + drift_y) / star.z * cy + cy)

            if not (0 <= sx < width - 1 and 0 <= sy < height - 1):
                star.x = random.uniform(-width, width)
                star.y = random.uniform(-height, height)
                star.z = DEPTH
                star.pz = DEPTH
                star.speed = random.uniform(0.6, 1.4)
                continue

            px = int((star.x + drift_x) / star.pz * cx + cx)
            py = int((star.y + drift_y) / star.pz * cy + cy)

            depth_ratio = 1.0 - (star.z / DEPTH)
            bucket = min(int(depth_ratio * len(glyphs_by_depth)), len(glyphs_by_depth) - 1)
            glyph, attr = glyphs_by_depth[bucket]

            if depth_ratio > 0.3:
                color = curses.color_pair(1)
            elif depth_ratio > 0.15:
                color = curses.color_pair(random.choice([2, 5]))
            else:
                color = curses.color_pair(random.choice([3, 4]))

            try:
                if depth_ratio > 0.5:
                    dx = sx - px
                    dy = sy - py
                    streak_len = max(1, int(math.hypot(dx, dy) * STREAK_MULTIPLIER * depth_ratio))
                    streak_len = min(streak_len, 8)

                    if streak_len > 1 and (dx != 0 or dy != 0):
                        dist = math.hypot(dx, dy)
                        if dist > 0:
                            ux, uy = dx / dist, dy / dist
                            streak_chars = ["|", "/", "-", "\\"]
                            angle = math.atan2(uy, ux)
                            ci = int((angle / math.pi * 4 + 4.5)) % 4
                            sc = streak_chars[ci]

                            for i in range(streak_len):
                                frac = i / streak_len
                                trail_x = int(sx - ux * i)
                                trail_y = int(sy - uy * i)
                                if 0 <= trail_x < width - 1 and 0 <= trail_y < height - 1:
                                    trail_attr = attr if frac < 0.4 else curses.A_DIM
                                    trail_color = color if frac < 0.6 else curses.color_pair(3)
                                    stdscr.addch(trail_y, trail_x, sc, trail_attr | trail_color)

                stdscr.addch(sy, sx, glyph, attr | color)

            except curses.error:
                pass

        if frame % 120 < 40:
            flash_t = (frame % 120) / 40.0
            alpha = math.sin(flash_t * math.pi)
            if alpha > 0.3:
                nebula_chars = ["~", "≈", "░", "·"]
                for _ in range(int(8 * alpha)):
                    nx = random.randint(1, width - 2)
                    ny = random.randint(1, height - 2)
                    nc = random.choice(nebula_chars)
                    try:
                        stdscr.addch(ny, nx, nc, curses.A_DIM | curses.color_pair(random.choice([4, 2])))
                    except curses.error:
                        pass

        try:
            brace = curses.A_DIM | curses.color_pair(6)

            top_bar = "─" * (width - 2)
            stdscr.addstr(0, 1, top_bar, brace)
            stdscr.addch(0, 0, "╭", brace)
            stdscr.addch(0, width - 2, "╮", brace)

            for y in range(1, height - 1):
                stdscr.addch(y, 0, "│", brace)
                if width - 2 > 0:
                    stdscr.addch(y, width - 2, "│", brace)

            bot_bar = "─" * (width - 2)
            stdscr.addstr(height - 1, 1, bot_bar, brace)
            stdscr.addch(height - 1, 0, "╰", brace)
            if width - 2 > 0:
                stdscr.addch(height - 1, width - 2, "╯", brace)

            cross_y = height // 3

            bow_max = max(2, width // 16)
            q1_x = int(width * 0.20)
            q3_x = int(width * 0.80)

            hex_top = int(height * 0.15)
            hex_bot = int(height * 0.85)

            for y in range(1, height - 1):
                if y <= hex_top:
                    frac = y / hex_top if hex_top > 0 else 0
                    bulge = int(frac * bow_max)
                elif y >= hex_bot:
                    frac = (height - 1 - y) / (height - 1 - hex_bot) if hex_bot < height - 1 else 0
                    bulge = int(frac * bow_max)
                else:
                    bulge = bow_max

                lx = q1_x - bulge
                if 1 <= lx < width - 2:
                    stdscr.addch(y, lx, "│", brace)

                rx = q3_x + bulge
                if 1 <= rx < width - 2:
                    stdscr.addch(y, rx, "│", brace)

            stdscr.addch(0, q1_x, "┬", brace)
            stdscr.addch(height - 1, q1_x, "┴", brace)
            stdscr.addch(0, q3_x, "┬", brace)
            stdscr.addch(height - 1, q3_x, "┴", brace)

            if 0 < cross_y < height - 1:
                if cross_y <= hex_top:
                    cfrac = cross_y / hex_top if hex_top > 0 else 0
                elif cross_y >= hex_bot:
                    cfrac = (height - 1 - cross_y) / (height - 1 - hex_bot) if hex_bot < height - 1 else 0
                else:
                    cfrac = 1.0
                cbulge = int(cfrac * bow_max)
                cl = q1_x - cbulge
                cr = q3_x + cbulge
                stdscr.addstr(cross_y, 1, "─" * (cl - 1), brace)
                stdscr.addch(cross_y, 0, "├", brace)
                stdscr.addch(cross_y, cl, "┼", brace)
                if cr + 1 < width - 2:
                    stdscr.addstr(cross_y, cr + 1, "─" * (width - 3 - cr), brace)
                stdscr.addch(cross_y, cr, "┼", brace)
                if width - 2 > 0:
                    stdscr.addch(cross_y, width - 2, "┤", brace)

        except curses.error:
            pass

        try:
            PY = height - 6
            db = curses.A_DIM | curses.color_pair(3)
            dc = curses.A_DIM | curses.color_pair(2)
            bc = curses.A_BOLD | curses.color_pair(2)
            by = curses.A_BOLD | curses.color_pair(5)
            bm = curses.A_BOLD | curses.color_pair(4)
            br = curses.A_BOLD | curses.color_pair(1)

            pw = width // 2
            px0 = (width - pw) // 2

            indent = [4, 2, 1, 0, 0]
            row_w = [pw - ind * 2 for ind in indent]
            row_x = [px0 + ind for ind in indent]

            def put(y, x, s, attr):
                if 0 <= y < height and 0 <= x < width - len(s):
                    stdscr.addstr(y, x, s, attr)

            def put_clipped(y, x, s, attr, rowi):
                rl = row_x[rowi]
                rr = row_x[rowi] + row_w[rowi]
                if y < 0 or y >= height:
                    return
                for ci, ch in enumerate(s):
                    cx = x + ci
                    if rl <= cx < rr and cx < width - 1:
                        try:
                            stdscr.addch(y, cx, ch, attr)
                        except curses.error:
                            pass

            top_edge = "╱" + "═" * (row_w[0] - 2) + "╲"
            put(PY, row_x[0], top_edge, db)

            for ri in range(1, 4):
                y = PY + ri
                put(y, row_x[ri], "│", db)
                put(y, row_x[ri] + row_w[ri] - 1, "│", db)

            bot_edge = "╚" + "═" * (row_w[4] - 2) + "╝"
            put(PY + 4, row_x[4], bot_edge, db)

            switches = [1, 1, 0, 1, 0, 1, 1, 0, 1, 1]
            blink_idx = int(t * 1.3) % len(switches)
            switches[blink_idx] = 1 - switches[blink_idx]

            sw_col = row_x[1] + 2
            for i, s in enumerate(switches):
                if sw_col >= row_x[1] + row_w[1] - 2:
                    break
                if s:
                    put_clipped(PY + 1, sw_col, "┬", dc, 1)
                    put_clipped(PY + 2, sw_col, "│", dc, 2)
                else:
                    put_clipped(PY + 1, sw_col, "│", db, 1)
                    put_clipped(PY + 2, sw_col, "┴", db, 2)
                sw_col += 3

            lights_start = sw_col + 2
            light_patterns = [
                [1,0,1,1,0,1],
                [0,1,0,1,1,0],
                [1,1,0,0,1,1],
            ]
            pat_idx = int(t * 0.8) % len(light_patterns)
            pat = light_patterns[pat_idx]
            blink2 = int(t * 2.5) % len(pat)

            lx = lights_start
            for i, on in enumerate(pat):
                if lx >= row_x[1] + row_w[1] - 2:
                    break
                lit = on if i != blink2 else 1 - on
                if lit:
                    put_clipped(PY + 1, lx, "●", bc if i % 3 != 0 else by, 1)
                else:
                    put_clipped(PY + 1, lx, "○", db, 1)
                lx += 3

            lx2 = lights_start
            pat2 = [1,1,0,1,0,0]
            blink3 = int(t * 1.7) % len(pat2)
            for i, on in enumerate(pat2):
                if lx2 >= row_x[2] + row_w[2] - 2:
                    break
                lit = on if i != blink3 else 1 - on
                if lit:
                    put_clipped(PY + 2, lx2, "●", bm if i % 2 == 0 else bc, 2)
                else:
                    put_clipped(PY + 2, lx2, "○", db, 2)
                lx2 += 3

            lever_x = lx + 3
            throttle_pos = 1 + int((math.sin(t * 0.15) + 1) * 1.0)
            if lever_x + 4 < row_x[1] + row_w[1]:
                put_clipped(PY + 1, lever_x, "╔╗", dc, 1)
                put_clipped(PY + 2, lever_x, "║║", bc, 2)
                put_clipped(PY + 3, lever_x, "╚╝", dc, 3)
                notch_row = min(max(1, throttle_pos), 3)
                put_clipped(PY + notch_row, lever_x + 3, "◄", by, notch_row)

            btn_x = lever_x + 7
            buttons = [("(●)", bc), ("(●)", bm), ("(●)", bc), ("(●)", by)]
            flash_btn = int(t * 1.1) % len(buttons)
            for i, (ch, attr) in enumerate(buttons):
                bx = btn_x + i * 4
                if bx + 3 >= row_x[1] + row_w[1] - 1:
                    break
                if i == flash_btn:
                    put_clipped(PY + 1, bx, "(●)", br, 1)
                else:
                    put_clipped(PY + 1, bx, ch, attr, 1)

            dial_chars = ["(│)", "(╱)", "(─)", "(╲)"]
            dial_x = btn_x
            d1 = int(t * 0.6) % 4
            d2 = int(t * 0.4 + 2) % 4
            d3 = int(t * 0.9 + 1) % 4
            for i, di in enumerate([d1, d2, d3]):
                dx = dial_x + i * 5
                if dx + 3 >= row_x[2] + row_w[2] - 1:
                    break
                put_clipped(PY + 2, dx, dial_chars[di], dc, 2)

            slider_x = row_x[3] + 3
            r3_end = row_x[3] + row_w[3] - 2
            sl_w = min(r3_end - slider_x, row_w[3] - 6)
            if sl_w >= 6:
                spos = int((math.sin(t * 0.2) + 1) / 2 * (sl_w - 2))
                track = list("╶" + "─" * (sl_w - 2) + "╴")
                if 0 <= spos + 1 < len(track):
                    track[spos + 1] = "█"
                put_clipped(PY + 3, slider_x, "".join(track), dc, 3)

            sw2_start = slider_x + sl_w + 2 if sl_w >= 6 else row_x[3] + 3
            switches2 = [0, 1, 1, 0, 1, 0]
            blink4 = int(t * 0.9) % len(switches2)
            switches2[blink4] = 1 - switches2[blink4]
            for i, s in enumerate(switches2):
                sc = sw2_start + i * 3
                if sc >= row_x[1] + row_w[1] - 1:
                    break
                if s:
                    put_clipped(PY + 1, sc, "┬", dc, 1)
                    put_clipped(PY + 2, sc, "│", dc, 2)
                else:
                    put_clipped(PY + 1, sc, "│", db, 1)
                    put_clipped(PY + 2, sc, "┴", db, 2)
        except curses.error:
            pass

        stdscr.refresh()


if __name__ == "__main__":
    signal.signal(signal.SIGINT, lambda *_: sys.exit(0))
    try:
        curses.wrapper(main)
    except KeyboardInterrupt:
        pass
