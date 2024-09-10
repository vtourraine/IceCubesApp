#if !os(visionOS) && !DEBUG
  import DesignSystem
  @preconcurrency import GiphyUISDK
  import SwiftUI
  import UIKit
  
  @MainActor
  struct GifPickerView: UIViewControllerRepresentable {
    @Environment(Theme.self) private var theme

    var completion: (String) -> Void
    var onShouldDismissGifPicker: () -> Void

    func makeUIViewController(context: Context) -> GiphyViewController {
      Giphy.configure(apiKey: "MIylJkNX57vcUNZxmSODKU9dQKBgXCkV")

      let controller = GiphyViewController()
      controller.swiftUIEnabled = true
      controller.mediaTypeConfig = [.gifs, .stickers, .recents]
      controller.delegate = context.coordinator
      controller.navigationController?.isNavigationBarHidden = true
      controller.navigationController?.setNavigationBarHidden(true, animated: false)

      GiphyViewController.trayHeightMultiplier = 1.0

      controller.theme = GPHTheme(type: theme.selectedScheme == .dark ? .darkBlur : .lightBlur)

      return controller
    }

    func updateUIViewController(_: UIViewControllerType, context _: Context) {}

    func makeCoordinator() -> Coordinator {
      GifPickerView.Coordinator(parent: self)
    }

    @MainActor
    class Coordinator: NSObject, GiphyDelegate {
      var parent: GifPickerView

      init(parent: GifPickerView) {
        self.parent = parent
      }

      nonisolated func didDismiss(controller _: GiphyViewController?) {
        Task { @MainActor in
          parent.onShouldDismissGifPicker()
        }
      }

      nonisolated func didSelectMedia(giphyViewController _: GiphyViewController, media: GPHMedia) {
        Task { @MainActor in
          let url = media.url(rendition: .fixedWidth, fileType: .gif)
          parent.completion(url ?? "")
        }
      }
    }
  }
#endif
