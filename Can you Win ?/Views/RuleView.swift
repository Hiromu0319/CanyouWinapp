import SwiftUI

struct RuleView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        
        ScrollView {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                }
                Text("Rule")
                    .font(.caprasimo(size: 40))
                
            }
        }
    }
}

struct RuleView_Previews: PreviewProvider {
    static var previews: some View {
        RuleView()
    }
}
