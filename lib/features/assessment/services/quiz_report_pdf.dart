import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:foundationx_frontend/core/models/quiz_assessment.dart';

/// Renders a QuizzAssessmentReport as a printable/shareable PDF, used by
/// the "Download Report" action on QuizReportScreen. Kept as pure
/// pdf-building logic (no I/O) so it's easy to test/reuse independent
/// of how the caller saves/shares the resulting bytes.
class QuizReportPdf {
  static Future<Uint8List> build(QuizzAssessmentReport report) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('${report.subject} Quiz Report', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Text('Grade: ${report.grade}'),
          if (report.quizzLevel != null) pw.Text('Level: ${report.quizzLevel}'),
          if (report.gradedAt != null) pw.Text('Graded: ${report.gradedAt}'),
          pw.SizedBox(height: 16),

          pw.Text(
            'Score: ${report.score}/${report.totalQuestions}'
            '${report.totalQuestions == 0 ? '' : ' (${(report.score / report.totalQuestions * 100).round()}%)'}',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          if (report.currentUnderstandingLevel.isNotEmpty)
            pw.Text('Understanding level: ${report.currentUnderstandingLevel}'),

          if (report.strengths.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text('Strengths', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ...report.strengths.map((s) => pw.Bullet(text: s)),
          ],

          if (report.growthAreas.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text('Growth Areas', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ...report.growthAreas.map((s) => pw.Bullet(text: s)),
          ],

          if (report.nextSteps.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text('Next Steps', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ...report.nextSteps.map((s) => pw.Bullet(text: s)),
          ],

          if (report.questionFeedback.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text('Question Review', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            ...report.questionFeedback.map(
              (item) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 10),
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Q${item.questionNumber}. ${item.questionText}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Your answer: ${item.studentAnswer}'),
                    if (!item.isCorrect) pw.Text('Correct answer: ${item.correctAnswer}'),
                    pw.Text(item.isCorrect ? 'Correct' : 'Incorrect'),
                  ],
                ),
              ),
            ),
          ],

          if (report.resources.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text('Further Reading', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ...report.resources.map(
              (r) => pw.Bullet(
                text: r.pageNumber == null || r.pageNumber!.isEmpty
                    ? r.bookName
                    : '${r.bookName} - page${r.pageNumber!.length > 1 ? 's' : ''} ${r.pageNumber!.join(', ')}',
              ),
            ),
          ],
        ],
      ),
    );

    return doc.save();
  }
}
