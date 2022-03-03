//
//  Picture.swift
//  AsyncList
//
//

import SwiftUI

struct PictureData: Codable {
    let id: String
    let author: String
    let width: Int
    let height: Int
    let url: String
    let download_url: String
}

struct PictureItemModel: ListItemModel {
    var pictureData: PictureData?
    var image: Image?

    mutating func fetchAdditionalData() async {
        guard let thePictureData = pictureData else { return }

        guard let imageUrl = URL(string: "https://picsum.photos/id/\(thePictureData.id)/200/150")
        else { return }
        do {
            let (imageData, _) = try await URLSession.shared.data(from: imageUrl)
            guard let uiImage = UIImage(data: imageData) else { return }
            try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * Float.random(in: 0.5...1.5)))
            image = Image(uiImage: uiImage)
        } catch {
            print(error.localizedDescription)
        }

    }
}

struct PictureListModel: ListModel {

    var lastPageFetched = -1

    init() {

    }

    mutating func fetchNextItems(count: Int) async -> [PictureItemModel] {
        guard
            let url = URL(
                string: "https://picsum.photos/v2/list?page=\(lastPageFetched + 1)&limit=\(count)")
        else { return [] }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            let decoder = JSONDecoder()
            let items = try decoder.decode([PictureData].self, from: data)
            lastPageFetched += 1
            print("Fetched page \(lastPageFetched)")
            return items.map { PictureItemModel(pictureData: $0) }
        } catch {
            print("No pictures found")
            print(error.localizedDescription)
            return []
        }

    }

    mutating func reset() {
        lastPageFetched = -1
    }
}

struct PictureListItemView: DynamicListItemView {

    @ObservedObject var itemViewModel: ListItemViewModel<PictureItemModel>

    init(itemViewModel: ListItemViewModel<PictureItemModel>) {
        self.itemViewModel = itemViewModel
    }

    @State var opacity: Double = 0

    var body: some View {
        VStack(alignment: .center) {
            if let thePictureData = itemViewModel.item.pictureData {
                Text("Author: \(thePictureData.author)")
                    .font(.system(.caption))
                if itemViewModel.dataFetchComplete,
                    let theImage = itemViewModel.item.image
                {
                    theImage
                        .resizable()
                        .scaledToFill()
                        .opacity(opacity)
                        .animation(.easeInOut(duration: 1), value: opacity)
                        .frame(maxWidth: .infinity, maxHeight: 190)
                        .clipped()
                        .onAppear {
                            opacity = 1
                        }
                        .padding((1 - opacity) * 80)
                } else {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }

        }
        .frame(maxWidth: .infinity, idealHeight: 220)
        .onAppear {
            if itemViewModel.dataFetchComplete {
                opacity = 1
            }
        }
        .onDisappear {
            opacity = 0
        }
    }
}
