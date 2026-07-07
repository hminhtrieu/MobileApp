import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flashcard/features/statistics/controllers/statistics_controller.dart';
import 'package:flashcard/features/subject/models/subject_model.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StatisticsController _controller = StatisticsController();

  List<SubjectModel> _subjects = [];
  SubjectModel? _selectedSubject;

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _statsData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_subjects.isEmpty) {
        _subjects = await _controller.getSubjects();
      }
      _statsData = await _controller.fetchStatistics(
        subjectId: _selectedSubject?.subjectId,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1A1C1E);
    final secondaryTextColor =
        Theme.of(context).textTheme.bodyMedium?.color ??
        const Color(0xFF71787F);
    final cardColor = Theme.of(context).cardColor;
    final borderColor = isDarkMode
        ? Colors.grey[800]!
        : const Color(0xFFE2E2E5);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Thống kê học tập',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1C648E)),
            )
          : _errorMessage != null
          ? Center(
              child: Text(
                'Lỗi: $_errorMessage',
                style: TextStyle(color: textColor),
              ),
            )
          : _buildBody(
              textColor,
              secondaryTextColor,
              cardColor,
              borderColor,
              isDarkMode,
            ),
    );
  }

  Widget _buildBody(
    Color textColor,
    Color secondaryTextColor,
    Color cardColor,
    Color borderColor,
    bool isDarkMode,
  ) {
    final data = _statsData ?? {};
    final totalDocuments = data['totalDocuments'] ?? 0;
    final totalFlashcards = data['totalFlashcards'] ?? 0;
    final totalQuizzes = data['totalQuizzes'] ?? 0;

    final hardCards = data['hardCards'] ?? 0;
    final mediumCards = data['mediumCards'] ?? 0;
    final easyCards = data['easyCards'] ?? 0;

    final averageScore = data['averageScore'] as double? ?? 0.0;
    final totalAttempts = data['totalAttempts'] ?? 0;
    final sumCorrect = data['sumCorrect'] ?? 0;
    final sumTotal = data['sumTotal'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubjectDropdown(textColor, cardColor, borderColor),
          const SizedBox(height: 24),

          _buildSectionTitle('Tổng quan tài nguyên', textColor),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Tài liệu',
                  totalDocuments.toString(),
                  Icons.description,
                  Colors.orange,
                  textColor,
                  secondaryTextColor,
                  cardColor,
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Flashcard',
                  totalFlashcards.toString(),
                  Icons.style,
                  Colors.purple,
                  textColor,
                  secondaryTextColor,
                  cardColor,
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Câu hỏi',
                  totalQuizzes.toString(),
                  Icons.quiz,
                  Colors.red,
                  textColor,
                  secondaryTextColor,
                  cardColor,
                  isDarkMode,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          _buildSectionTitle('Hiệu suất làm bài Quiz', textColor),
          const SizedBox(height: 12),
          _buildQuizPerformanceCard(
            averageScore,
            totalAttempts,
            sumCorrect,
            sumTotal,
          ),

          const SizedBox(height: 32),
          _buildSectionTitle('Mức độ ghi nhớ Flashcard', textColor),
          const SizedBox(height: 12),
          _buildMemoryLevelBars(
            hardCards,
            mediumCards,
            easyCards,
            textColor,
            cardColor,
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectDropdown(
    Color textColor,
    Color cardColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SubjectModel?>(
          value: _selectedSubject,
          hint: Text(
            'Tất cả môn học',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          isExpanded: true,
          dropdownColor: cardColor,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF71787F)),
          items: [
            DropdownMenuItem<SubjectModel?>(
              value: null,
              child: Text(
                'Tất cả môn học',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            ..._subjects.map((subject) {
              return DropdownMenuItem<SubjectModel?>(
                value: subject,
                child: Text(
                  subject.subjectName,
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              );
            }),
          ],
          onChanged: (SubjectModel? newValue) {
            setState(() {
              _selectedSubject = newValue;
            });
            _loadData();
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: GoogleFonts.quicksand(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    Color textColor,
    Color secondaryTextColor,
    Color cardColor,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              color: secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizPerformanceCard(
    double avgScore,
    int attempts,
    int sumCorrect,
    int sumTotal,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C648E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C648E).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Điểm trung bình',
                    style: GoogleFonts.quicksand(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        avgScore.toStringAsFixed(1),
                        style: GoogleFonts.quicksand(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6, left: 4),
                        child: Text(
                          '/ 10',
                          style: GoogleFonts.quicksand(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      attempts.toString(),
                      style: GoogleFonts.quicksand(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Lượt làm',
                      style: GoogleFonts.quicksand(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng số câu đã làm đúng',
                  style: GoogleFonts.quicksand(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$sumCorrect / $sumTotal',
                  style: GoogleFonts.quicksand(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryLevelBars(
    int hard,
    int medium,
    int easy,
    Color textColor,
    Color cardColor,
    bool isDarkMode,
  ) {
    final total = hard + medium + easy;
    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('Chưa có dữ liệu Flashcard')),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildBarRow('Chưa thuộc', hard, total, Colors.red, textColor),
          const SizedBox(height: 12),
          _buildBarRow('Tạm nhớ', medium, total, Colors.orange, textColor),
          const SizedBox(height: 12),
          _buildBarRow('Đã thuộc', easy, total, Colors.green, textColor),
        ],
      ),
    );
  }

  Widget _buildBarRow(
    String label,
    int count,
    int total,
    Color color,
    Color textColor,
  ) {
    final double percentage = count / total;
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 32,
          child: Text(
            count.toString(),
            textAlign: TextAlign.right,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
