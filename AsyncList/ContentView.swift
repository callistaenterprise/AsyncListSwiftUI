//
//  ContentView.swift
//  AsyncList
//
//  Created by Anders Forssell on 2022-02-28.
//

import SwiftUI

let pictureListViewModel = ListViewModel<PictureListModel>(itemBatchCount: 10, prefetchMargin: 1)

struct ContentView: View {

    var body: some View {

        DynamicList<PictureListItemView, PictureListModel>(listViewModel: pictureListViewModel)
            .listStyle(.plain)
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {

        ContentView()

    }
}
