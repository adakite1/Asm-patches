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

ORIGINAL_INSTRUCTION = int.from_bytes(b'\x81\x00\xA0\xE1', "little")
OFFSET_US = 0x6D578
OFFSET_EU = 0x6D910
OFFSET_JP = 0x6D860

class PatchHandler(AbstractPatchHandler, DependantPatch):

    @property
    def name(self) -> str:
        return 'MoreSamplesAndPresets'

    @property
    def description(self) -> str:
        return "Enables support for music files utilizing extended 32-bit offset pointers over the 16-bit offset pointers used by the game's music engine by default to store samples and presets."

    @property
    def author(self) -> str:
        return 'adakite'

    @property
    def version(self) -> str:
        return '0.1.0'

    def depends_on(self) -> List[str]:
        return ["ExtraSpace"]

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
