//
//  ProjectSpeakingRateView.swift
//  highpitch
//
//  Created by 이용준의 Macbook on 11/15/23.
//

import Charts
import SwiftUI

struct ProjectSpeakingRateChart: View {
    
    @Environment(ProjectManager.self)
    private var projectManager
    @State
    var rawSelected: Int?
    @State
    var rawSelectedRange: ClosedRange<Int>?
    
    var body: some View {
        VStack(alignment: .leading, spacing: .HPSpacing.xsmall) {
            Text("말 빠르기 범위")
                .systemFont(.subTitle)
                .foregroundStyle(Color.HPTextStyle.darker)
            ZStack(alignment: .topLeading) {
                Text("(속도: SPM)")
                    .systemFont(.caption2)
                    .foregroundStyle(Color.HPTextStyle.base)
                    .offset(y: -12)
                graph
                    .padding(.leading, .HPSpacing.xxsmall)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(.top, .HPSpacing.small)
        .padding(.bottom, .HPSpacing.xxsmall)
        .padding(.horizontal, .HPSpacing.small)
        .frame(
            minWidth: 286,
            maxWidth: .infinity,
            minHeight: 286,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .background(Color.HPComponent.Section.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.HPComponent.shadowColor ,radius: 10, y: 4)
    }
}

extension ProjectSpeakingRateChart {
    @ViewBuilder
    var graph: some View {
        let practices = projectManager.current?.practices.sorted(by: { $0.creatAt < $1.creatAt })
        
        if let practices = practices, !practices.isEmpty {
            let title = "말 빠르기 범위"
            let range = spmAxisRange()
            let rawRange = spmValueRange()
            
            Chart {
                /// 선 그래프
                ForEach(practices) { practice in
                    if practice.summary.minSpm < practice.summary.maxSpm {
                        BarMark(
                            x: .value("연습회차", practice.index + 1),
                            yStart: .value(title, practice.summary.minSpm),
                            yEnd: .value(title, practice.summary.maxSpm),
                            width: .fixed(16)
                        )
                        .clipShape(Capsule())
                        .foregroundStyle(Color("FFBF65"))
                    }
                    if practice.summary.minSpm == practice.summary.maxSpm {
                        PointMark(
                            x: .value("연습회차", practice.index + 1),
                            y: .value(title, practice.summary.minSpm)
                        )
                        .symbolSize(200)
                        .foregroundStyle(Color("FFBF65"))
                    }
                    /// 모든 연습 중에도 가장 빠르거나 가장 느린 경우가 있다면 추가합니다.
                    if practice.summary.maxSpm == rawRange.last! {
                        PointMark(
                            x: .value("연습회차", practice.index + 1),
                            y: .value(title, practice.summary.maxSpm)
                        )
                        .symbolSize(113)
                        .offset(y: practice.summary.maxSpm == practice.summary.minSpm ? 0 : 8)
                        .foregroundStyle(Color.HPGray.systemWhite)
                    }
                    if practice.summary.minSpm == rawRange.first! {
                        PointMark(
                            x: .value("연습회차", practice.index + 1),
                            y: .value(title, practice.summary.minSpm)
                        )
                        .symbolSize(113)
                        .offset(y: practice.summary.maxSpm == practice.summary.minSpm ? 0 : -8)
                        .foregroundStyle(Color.HPGray.systemWhite)
                    }
                }
                /// 호버 효과
                if let selected {
                    RuleMark(
                        x: .value("Selected", selected + 1)
                    )
                    /// 호버 시 점선
                    .foregroundStyle(Color.clear)
                    .zIndex(0)
                    /// 호버 시 overlay
                    .annotation(
                        position: .leading, spacing: 0,
                        overflowResolution: .init(
                            x: .fit(to: .chart),
                            y: .disabled
                        )
                    ) {
                        VStack(spacing: 0) {
                            // swiftlint: disable line_length
                            if practices[selected].summary.minSpm < practices[selected].summary.maxSpm {
                                Text("\(Int(practices[selected].summary.minSpm))-\(Int(practices[selected].summary.maxSpm)) SPM")
                                    .systemFont(.caption2, weight: .bold)
                                    .foregroundStyle(Color.HPTextStyle.dark)
                            } else if practices[selected].summary.minSpm == practices[selected].summary.maxSpm {
                                Text("\(Int(practices[selected].summary.minSpm)) SPM")
                                    .systemFont(.caption2, weight: .bold)
                                    .foregroundStyle(Color.HPTextStyle.dark)
                            }
                            // swiftlint: enable line_length
                            HStack(spacing: 0) {
                                Text("\(Date().createAtToYMD(input: practices[selected].creatAt))")
                                    .systemFont(.caption2, weight: .medium)
                                    .foregroundStyle(Color.HPTextStyle.light)
                                Text(" | ")
                                    .systemFont(.caption2, weight: .medium)
                                    .foregroundStyle(Color.HPTextStyle.light)
                                Text("\(Date().createAtToHM(input: practices[selected].creatAt))")
                                    .systemFont(.caption2, weight: .medium)
                                    .foregroundStyle(Color.HPTextStyle.light)
                            }
                            .zIndex(5)
                        }
                        .padding(.horizontal, .HPSpacing.xxxsmall)
                        .background(Color.HPGray.systemWhite)
                        .cornerRadius(5)
                        .shadow(color: .HPComponent.shadowBlackColor, radius: 8)
                        .offset(x: 60)
                    }
                }
            }
            /// 호버 control
            .chartXSelection(value: $rawSelected)
            .chartXSelection(range: $rawSelectedRange)
            /// chart의 scroll을 설정합니다.
            .chartScrollableAxes(.horizontal)
            .chartScrollPosition(initialX: practices.count)
            .chartXScale(domain: [
                0.2, Double(practices.count) + 0.8
            ])
            /// 화면에 7회차까지의 연습을 표출합니다.
            .chartXVisibleDomain(length: 7)
            /// y축은 최저 값과 최고 값 차이의 1/8까지 표출합니다.
            .chartYScale(domain: [
                range.first! -
                (range.last! - range.first!) / 8,
                range.last! +
                (range.last! - range.first!) / 8
            ])
            /// x축 값
            .chartXAxis {
                AxisMarks(values: Array(stride(from: 1, to: practices.count + 2, by: 1))) { value in
                    AxisValueLabel(centered: false) {
                        Text("\(value.index + 1)회차")
                            .offset(x: -20)
                            .fixedSize()
                            .systemFont(.caption)
                            .foregroundStyle(Color.HPTextStyle.base)
                            .padding(.trailing, 18)
                    }
                }
            }
            /// y축 값
            .chartYAxis {
                /// y축은 5개의 값이 나타나도록
                /// 최저 값과 최고 값 차이의 1/4 간격으로 설정합니다.
                AxisMarks(position: .leading, values: Array(stride(
                    from: range.first!,
                    through: range.last!,
                    by: (range.last! - range.first!) / 4
                ))) { value in
                    AxisValueLabel(centered: false) {
                        if value.index % 2 == 0 {
                            let axisValue = Double(value.index)
                                * (range.last! - range.first!) / 4
                                + range.first!
                            Text("\(axisValue, specifier: "%.1f")")
                            .systemFont(.caption)
                            .foregroundStyle(Color.HPTextStyle.base)
                            .padding(.trailing, 18)
                        }
                    }
                    AxisGridLine()
                }
            }
            .chartLegend(.hidden)
        }
    }
}

extension ProjectSpeakingRateChart {
    /// YAxis 범위
    func spmValueRange() -> [Double] {
        var maxOf = 0.0
        var minOf = 9999.9
        let practices = projectManager.current?.practices.sorted(
            by: { $0.summary.spmAverage < $1.summary.spmAverage }
        )
        if let practices = practices, !practices.isEmpty {
            for practice in practices {
                maxOf = max(maxOf, practice.summary.maxSpm)
                minOf = min(minOf, practice.summary.minSpm)
            }
        }
        if (maxOf < minOf) {
            return [300.0, 400.0]
        } else { return [minOf, maxOf] }
    }
    
    func spmAxisRange() -> [Double] {
        let answer = spmValueRange()
        if (answer.first! == answer.last!) {
            return [answer.first! - 50.0, answer.first! + 50.0]
        } else { return answer }
    }
    
    /// 호버 관련 변수
    var selected: Int? {
        let practices = projectManager.current?.practices.sorted(by: { $0.index < $1.index })
        if let practices = practices {
            if let rawSelected {
                return practices.first(where: {
                    return ($0.index ... $0.index + 1).contains(rawSelected)
                })?.index
            } else if let selectedRange, selectedRange.lowerBound == selectedRange.upperBound {
                return selectedRange.lowerBound
            }
            return nil
        } else { return nil }
    }
    var selectedRange: ClosedRange<Int>? {
        let practices = projectManager.current?.practices.sorted(by: { $0.index < $1.index })
        if let practices = practices {
            if let rawSelectedRange {
                let lower = practices.first(where: {
                    return ($0.index ... $0.index + 1).contains(rawSelectedRange.lowerBound)
                })?.index
                let upper = practices.first(where: {
                    return ($0.index ... $0.index + 1).contains(rawSelectedRange.upperBound)
                })?.index
                
                if let lower, let upper {
                    return lower ... upper
                }
            }
            return nil
        } else { return nil }
    }
}
