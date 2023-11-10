 #  Copyright 2020-2023 Capypara and the SkyTemple Contributors
 #
 #  This file is part of SkyTemple.
 #
 #  SkyTemple is free software: you can redistribute it and/or modify
 #  it under the terms of the GNU General Public License as published by
 #  the Free Software Foundation, either version 3 of the License, or
 #  (at your option) any later version.
 #
 #  SkyTemple is distributed in the hope that it will be useful,
 #  but WITHOUT ANY WARRANTY; without even the implied warranty of
 #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #  GNU General Public License for more details.
 #
 #  You should have received a copy of the GNU General Public License
 #  along with SkyTemple.  If not, see <https://www.gnu.org/licenses/>.
from typing import Callable, List

from ndspy.rom import NintendoDSRom

from skytemple_files.common.util import *
from skytemple_files.common.ppmdu_config.data import Pmd2Data, GAME_VERSION_EOS, GAME_REGION_US, GAME_REGION_EU, GAME_REGION_JP
from skytemple_files.patch.category import PatchCategory
from skytemple_files.patch.handler.abstract import AbstractPatchHandler, DependantPatch
from skytemple_files.common.i18n_util import f, _

ORIGINAL_INSTRUCTION = int.from_bytes(b'\x00\x00\x50\xE3', "little")
OFFSET_US = 0x7D284
OFFSET_EU = 0x7D61C
OFFSET_JP = 0x7D56C

class PatchHandler(AbstractPatchHandler, DependantPatch):

    @property
    def name(self) -> str:
        return 'FifoHooks'

    @property
    def description(self) -> str:
        return "This patch registers a new IPC channel, channel 18 (0x12) on both the arm7 and arm9 game binaries so that patches can communicate easily between the two processors."

    @property
    def author(self) -> str:
        return 'Adakite'

    @property
    def version(self) -> str:
        return '1.0.1'

    def depends_on(self) -> List[str]:
        return []

    def is_applied(self, rom: NintendoDSRom, config: Pmd2Data) -> bool:
        if config.game_version == GAME_VERSION_EOS:
            if config.game_region == GAME_REGION_US:
                return read_u32(rom.arm9, OFFSET_US) != ORIGINAL_INSTRUCTION
            if config.game_region == GAME_REGION_EU:
                return read_u32(rom.arm9, OFFSET_EU) != ORIGINAL_INSTRUCTION
            if config.game_region == GAME_REGION_JP:
                return read_u32(rom.arm9, OFFSET_JP) != ORIGINAL_INSTRUCTION
        raise NotImplementedError()

    def apply(self, apply: Callable[[], None], rom: NintendoDSRom, config: Pmd2Data) -> None:
         # Apply the patch
         apply()

    def unapply(self, unapply: Callable[[], None], rom: NintendoDSRom, config: Pmd2Data):
        raise NotImplementedError()
