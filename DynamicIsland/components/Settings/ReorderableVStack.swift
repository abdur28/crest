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

/// A vertical list whose rows can be dragged to reorder. Unlike `List`'s
/// `.onMove` (which is unreliable with multiple sections/ForEach on macOS),
/// this drives reordering directly from a drag gesture, so a single unified
/// list stays smooth and predictable.
struct ReorderableVStack<Item: Identifiable & Equatable, Content: View>: View {
    @Binding var items: [Item]
    var rowHeight: CGFloat
    @ViewBuilder var content: (Item) -> Content

    @State private var draggingIndex: Int?
    @State private var dragOffset: CGFloat = 0

    init(
        items: Binding<[Item]>,
        rowHeight: CGFloat = 44,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self._items = items
        self.rowHeight = rowHeight
        self.content = content
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                HStack(spacing: 8) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(.tertiary)
                        .font(.system(size: 12, weight: .semibold))
                    content(item)
                }
                .padding(.horizontal, 12)
                .frame(height: rowHeight)
                .contentShape(Rectangle())
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(draggingIndex == index ? Color.primary.opacity(0.08) : .clear)
                )
                .offset(y: draggingIndex == index ? dragOffset : 0)
                .zIndex(draggingIndex == index ? 1 : 0)
                .gesture(
                    DragGesture(minimumDistance: 10, coordinateSpace: .global)
                        .onChanged { value in
                            if draggingIndex == nil { draggingIndex = index }
                            dragOffset = value.translation.height
                        }
                        .onEnded { value in
                            if let from = draggingIndex {
                                moveItem(from: from, translationHeight: value.translation.height)
                            }
                            withAnimation(.snappy(duration: 0.2)) {
                                draggingIndex = nil
                                dragOffset = 0
                            }
                        }
                )

                if index != items.count - 1 {
                    Divider().opacity(0.4)
                }
            }
        }
    }

    private func moveItem(from fromIndex: Int, translationHeight: CGFloat) {
        guard fromIndex < items.count else { return }
        let moveOffset = Int((translationHeight / rowHeight).rounded())
        var toIndex = fromIndex + moveOffset
        toIndex = max(0, min(items.count - 1, toIndex))
        guard fromIndex != toIndex else { return }
        // Mutate a local copy and write back once. Two separate binding writes
        // (remove then insert) can round-trip through a sanitizing getter and
        // reintroduce the just-removed element as a duplicate.
        var newItems = items
        let item = newItems.remove(at: fromIndex)
        newItems.insert(item, at: toIndex)
        items = newItems
    }
}
