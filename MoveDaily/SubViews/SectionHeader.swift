//
//  SectionHeader.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 03/03/2026.
//

import SwiftUI

struct SectionHeader: View {
    let title:String
    var body: some View {
            Text(title)
                .font(.title3.bold())
        }
    }

#Preview {
    SectionHeader(title: "hii")
}
