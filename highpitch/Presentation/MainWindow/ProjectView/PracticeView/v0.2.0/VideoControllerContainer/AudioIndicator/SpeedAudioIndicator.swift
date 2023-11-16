//
//  SpeedAudioIndicator.swift
//  highpitch
//
//  Created by yuncoffee on 11/9/23.
//

import SwiftUI
import Charts
#if PREVIEW
import SwiftData
#endif

struct SpeedAudioIndicator: View {
    @Environment(PracticeViewStore.self)
    var viewStore
    
    @State
    private var duration: Double = 1
    
#if PREVIEW
    // MARK: - MockData
    @Query(sort: \PracticeModel.creatAt)
    var practices: [PracticeModel]
#endif
    
    var body: some View {
        ZStack(alignment: .leading) {
            GeometryReader { geometry in
                let widthPercent = geometry.size.width * 0.01
                ForEach(viewStore.getSortedSentences()) { sentence in
                    let isSlowSentence = viewStore.isSlowSentence(sentenceIndex: sentence.index)
                    let isFastSentence = viewStore.isFastSentence(sentenceIndex: sentence.index)
                    let xRatio = Double(sentence.startAt * 100) / duration
                    let width = Double(sentence.endAt * 100) / duration - Double(sentence.startAt * 100) / duration
                    if isSlowSentence || isFastSentence {
                        VStack {
                            let _width = widthPercent * width
                            Rectangle()
                                .frame(
                                    width: _width,
                                    height: 32
                                )
                                .foregroundStyle(
                                    isSlowSentence
                                    ? Color.HPGreen.base
                                    : Color.HPOrange.base
                                )
                        }
                        .offset(x: widthPercent * xRatio)
                        .frame(maxHeight: .infinity)
                        .onTapGesture {
                            viewStore.playMediaFromSentence(atTime: Double(sentence.startAt), index: sentence.index)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, .HPSpacing.xxxsmall)
        .frame(maxWidth:.infinity, maxHeight: 32, alignment: .leading)
        .onAppear {
            // MARK: - Add MockData
#if PREVIEW
            if let sample = practices.first {
                viewStore.practice = sample
            }
            let url = Bundle.main.url(forResource: "20231107202138", withExtension: "m4a")
            if let url = url {
                viewStore.practice.audioPath = url
                do {
                    try viewStore.mediaManager.registerAudio(url: url)
                } catch {
                    print(error)
                }
            }
#endif
            duration = viewStore.mediaManager.getDuration() * 1000
        }
    }
}

extension SpeedAudioIndicator {
    @ViewBuilder
    var chartView: some View {
        let sentences = viewStore.getSortedSentences()
        let epmRange = viewStore.getEpmRange()
        let linearGradient = LinearGradient(
            gradient: Gradient(
                colors: [.HPOrange.base, .HPOrange.base.opacity(0)]),
            startPoint: .top,
            endPoint: .bottom
        )
        Chart {
            ForEach(sentences) { sentence in
                LineMark(
                    x: .value("sentenceIndex", sentence.index),
                    y: .value("EPM", sentence.epmValue)
                )
                .foregroundStyle(Color.HPOrange.base)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            ForEach(sentences) { sentence in
                AreaMark(
                    x: .value("sentenceIndex", sentence.index),
                    y: .value("EPM", sentence.epmValue)
                )
            }
            .foregroundStyle(linearGradient)
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartXScale(domain: .automatic)
        .chartYScale(domain: .automatic)
        .chartOverlay { proxy in
             GeometryReader { geometry in
                 ZStack(alignment: .top) {
                     Rectangle().fill(.clear).contentShape(Rectangle())
                         .onTapGesture { location in
                             print(proxy, geometry, location)
                         }
                 }
             }
         }
    }
}

#Preview {
    let modelContainer = SwiftDataMockManager.previewContainer
    
    return VStack {
        SpeedAudioIndicator()
            .modelContainer(modelContainer)
            .environment(PracticeViewStore(
                practice: PracticeModel(
                    practiceName: "",
                    index: 0,
                    isVisited: false,
                    creatAt: "",
                    utterances: [],
                    summary: PracticeSummaryModel()
                ),
                mediaManager: MediaManager()))
    }
    .border(.blue)
    .frame(maxWidth: 800)
    .padding(32)
}
