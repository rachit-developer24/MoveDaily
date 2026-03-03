//
//  Cards.swift
//  MoveDaily
//
//  Created by Rachit Sharma on 03/03/2026.
//

import Foundation
import SwiftUI

struct Card<Content: View>: View {
   @ViewBuilder var content: Content
   var body: some View {
       VStack(alignment: .leading, spacing: 12) {
           content
       }
       .padding(16)
       .background(Color(.secondarySystemGroupedBackground))
       .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
   }
}
