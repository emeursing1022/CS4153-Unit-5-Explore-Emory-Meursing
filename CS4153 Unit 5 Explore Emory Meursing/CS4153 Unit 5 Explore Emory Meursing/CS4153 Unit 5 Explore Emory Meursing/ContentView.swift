//
//  CS4153_Unit_5_Explore_Emory_MeursingApp.swift
//  CS4153 Unit 5 Explore Emory Meursing
//
//  Created by Sarah Luster on 4/29/25.
//

import SwiftUI
import PencilKit

class DrawingViewModel: ObservableObject {
    @Published var canvasView = PKCanvasView()
    @Published var toolPicker = PKToolPicker()
    @Published var selectedColor: Color = .black
    @Published var selectedTool: PKInkingTool.InkType = .pen

    init() {
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        updateTool()
    }

    func updateTool() {
        let uiColor = UIColor(selectedColor)
        let tool = PKInkingTool(selectedTool, color: uiColor, width: 5)
        canvasView.tool = tool
    }

    func clearCanvas() {
        canvasView.drawing = PKDrawing()
    }

    func exportDrawing() -> UIImage? {
        let drawing = canvasView.drawing
        return drawing.image(from: canvasView.bounds, scale: 1.0)
    }
}

struct CanvasView: UIViewRepresentable {
    @ObservedObject var viewModel: DrawingViewModel

    func makeUIView(context: Context) -> PKCanvasView {
        viewModel.canvasView.drawingPolicy = .anyInput
        return viewModel.canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Tool and drawing updates handled via ViewModel
    }
}

struct DrawingAppView: View {
    @StateObject private var viewModel = DrawingViewModel()

    var body: some View {
        VStack {
            HStack {
                ColorPicker("Color", selection: $viewModel.selectedColor)
                    .onChange(of: viewModel.selectedColor) { _ in
                        viewModel.updateTool()
                    }
                Picker("Tool", selection: $viewModel.selectedTool) {
                    Text("Pen").tag(PKInkingTool.InkType.pen)
                    Text("Pencil").tag(PKInkingTool.InkType.pencil)
                    Text("Marker").tag(PKInkingTool.InkType.marker)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: viewModel.selectedTool) { _ in
                    viewModel.updateTool()
                }
                Button("Clear") {
                    viewModel.clearCanvas()
                }
                Button("Export") {
                    if let image = viewModel.exportDrawing() {
                        // Export logic here (e.g., save to photo library)
                        print("Exported image size: \(image.size)")
                    }
                }
            }
            .padding()

            CanvasView(viewModel: viewModel)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 5)
                .padding()
        }
    }
}
