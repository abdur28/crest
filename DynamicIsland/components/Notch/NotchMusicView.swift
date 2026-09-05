/*
 * Atoll (DynamicIsland)
 * Copyright (C) 2024-2026 Atoll Contributors
 * Modified 2026 by Bytesphere. Distributed as "Crest".
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

import SwiftUI

/// The dedicated Music tab. Shows only the media player (no calendar or camera),
/// using the same `MusicPlayerView` as Home. The notch is given extra width
/// (see `ContentView.dynamicNotchSize`) so the player has more room to breathe.
struct NotchMusicView: View {
    @EnvironmentObject var vm: DynamicIslandViewModel
    var albumArtNamespace: Namespace.ID

    var body: some View {
        MusicPlayerView(albumArtNamespace: albumArtNamespace)
            .frame(maxWidth: .infinity, alignment: .leading)
            .blur(radius: vm.notchState == .closed ? 30 : 0)
            .padding(8)
    }
}
