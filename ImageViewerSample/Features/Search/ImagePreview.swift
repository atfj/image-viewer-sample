//
//  ImagePreviewView.swift
//  ImageViewerSample
//
//  Created by Atsuhiro Fujita on 7/13/25.
//

import SwiftUI

struct ImagePreview: View {
    let url: URL?
    @Environment(\.dismiss) var dismiss
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    @State private var displayedImageSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            let safeAreaInsets = geometry.safeAreaInsets
            let safeAreaSize = CGSize(
                width: geometry.size.width + safeAreaInsets.leading + safeAreaInsets.trailing,
                height: geometry.size.height + safeAreaInsets.top + safeAreaInsets.bottom
            )
            ZStack(alignment: .topTrailing) {
                Color.black.ignoresSafeArea()
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .modifier(ImageSizeReader(size: $displayedImageSize))
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                SimultaneousGesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            scale = lastScale * value
                                        }
                                        .onEnded { _ in
                                            withAnimation(.spring()) {
                                                scale = min(max(1.0, scale), 5.0)
                                                lastScale = scale
                                                
                                                if scale == 1.0 {
                                                    offset = .zero
                                                    lastOffset = .zero
                                                } else {
                                                    offset = clampedOffset(
                                                        offset,
                                                        container: safeAreaSize,
                                                        imageSize: CGSize(width: displayedImageSize.width * scale, height: displayedImageSize.height * scale)
                                                    )
                                                    lastScale = scale
                                                }
                                            }
                                        },
                                    DragGesture()
                                        .onChanged { value in
                                            if scale > 1.0 {
                                                offset = CGSize(
                                                    width: lastOffset.width + value.translation.width,
                                                    height: lastOffset.height + value.translation.height
                                                )
                                            }
                                        }
                                        .onEnded { _ in
                                            withAnimation(.spring()) {
                                                offset = clampedOffset(
                                                    offset,
                                                    container: safeAreaSize,
                                                    imageSize: CGSize(width: displayedImageSize.width * scale, height: displayedImageSize.height * scale)
                                                )
                                                lastOffset = offset
                                            }
                                        }
                                )
                                
                            )
                            .onTapGesture(count: 2) {
                                withAnimation(.spring()) {
                                    scale = 1.0
                                    lastScale = 1.0
                                    offset = .zero
                                    lastOffset = .zero
                                }
                            }
                            .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                    case .failure:
                        Image(systemName: "xmark.octagon.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    @unknown default:
                        EmptyView()
                    }
                }
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                        .padding()
                }
            }
        }
    }
    
    private func displayedImageSize(for container: CGSize, imageSize: CGSize?, scale: CGFloat) -> CGSize {
        guard let imageSize = imageSize else { return container }
        let containerAspect = container.width / container.height
        let imageAspect = imageSize.width / imageSize.height

        var fittedWidth: CGFloat
        var fittedHeight: CGFloat

        if imageAspect > containerAspect {
            // Image is wider than container
            fittedWidth = container.width
            fittedHeight = container.width / imageAspect
        } else {
            // Image is taller than container
            fittedHeight = container.height
            fittedWidth = container.height * imageAspect
        }

        return CGSize(width: fittedWidth * scale, height: fittedHeight * scale)
    }
    
    private func clampedOffset(_ offset: CGSize, container: CGSize, imageSize: CGSize) -> CGSize {
        guard imageSize.width > 0, imageSize.height > 0 else { return .zero }
        let horizontalLimit = max((imageSize.width - container.width) / 2, 0)
        let verticalLimit = max((imageSize.height - container.height) / 2, 0)
        return CGSize(
            width: min(max(offset.width, -horizontalLimit), horizontalLimit),
            height: min(max(offset.height, -verticalLimit), verticalLimit)
        )
    }
}

struct ImageSizeReader: ViewModifier {
    @Binding var size: CGSize

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: ImageSizePreferenceKey.self, value: proxy.size)
                }
            )
            .onPreferenceChange(ImageSizePreferenceKey.self) { newSize in
                if newSize != .zero {
                    size = newSize
                }
            }
    }
}

private struct ImageSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
