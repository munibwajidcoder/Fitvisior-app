import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'consent_privacy_screen.dart';

class AgeEligibilityScreen extends StatefulWidget {
  const AgeEligibilityScreen({super.key});

  @override
  State<AgeEligibilityScreen> createState() => _AgeEligibilityScreenState();
}

class _AgeEligibilityScreenState extends State<AgeEligibilityScreen> {
  bool _confirmed = false;

  // Date pickers — default: 18 OCT 2003
  int _selectedDay = 18;
  String _selectedMonth = 'OCT';
  int _selectedYear = 2003;

  final List<int> _days = List.generate(31, (i) => i + 1);
  final List<String> _months = [
    'JAN', 'FÉV', 'MAR', 'AVR', 'MAI', 'JUN',
    'JUL', 'AOÛ', 'SEP', 'OCT', 'NOV', 'DÉC',
  ];
  final List<int> _years = List.generate(100, (i) => 2024 - i);

  int get _calculatedAge {
    final monthIndex = _months.indexOf(_selectedMonth) + 1;
    final birthDate = DateTime(_selectedYear, monthIndex, _selectedDay);
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  bool get _isEligible => _calculatedAge >= 13;

  @override
  Widget build(BuildContext context) {
    final int age = _calculatedAge;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),

                // ---- TOP APP BAR ----
                Row(
                  children: [
                    InkWell(
                      onTap: () { if (Navigator.canPop(context)) Navigator.pop(context); },
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Icon(Icons.chevron_left_rounded, size: 28,
                            color: Color(0xFF0F172A)),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Image.asset('assets/images/logo.png', width: 28, height: 28),
                  ],
                ),

                const SizedBox(height: 18),

                // ---- TITLE ----
                Text(
                  "Âge & Éligibilité",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.6,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Fitvisor exige que les utilisateurs aient au moins 13 ans pour générer des silhouettes d'essayage 3D personnalisées et stocker des données de morphologie biométrique.",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 20),

                // ---- DATE CARD ----
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Calendar Icon + Badge
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 62,
                            height: 62,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDE9FE),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F0FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 22,
                                  color: Color(0xFF6D28D9),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF43F5E),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.circle, size: 6,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Minimum Age Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 14,
                                color: Color(0xFF64748B)),
                            const SizedBox(width: 6),
                            Text(
                              "Âge minimum : 13 ans",
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // DATE OF BIRTH label
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "DATE DE NAISSANCE",
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF94A3B8),
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Three Column Date Pickers
                      Row(
                        children: [
                          // DAY
                          Expanded(
                            child: _buildDateColumn(
                              label: "JOUR",
                              value: _selectedDay.toString(),
                              onUp: () => setState(() {
                                _selectedDay =
                                    (_selectedDay % _days.length) + 1;
                              }),
                              onDown: () => setState(() {
                                _selectedDay = _selectedDay == 1
                                    ? _days.length
                                    : _selectedDay - 1;
                              }),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // MONTH
                          Expanded(
                            child: _buildDateColumn(
                              label: "MOIS",
                              value: _selectedMonth,
                              onUp: () => setState(() {
                                int idx = _months.indexOf(_selectedMonth);
                                _selectedMonth =
                                    _months[(idx + 1) % _months.length];
                              }),
                              onDown: () => setState(() {
                                int idx = _months.indexOf(_selectedMonth);
                                _selectedMonth =
                                    _months[(idx - 1 + _months.length) % _months.length];
                              }),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // YEAR
                          Expanded(
                            child: _buildDateColumn(
                              label: "ANNÉE",
                              value: _selectedYear.toString(),
                              onUp: () => setState(() {
                                int idx = _years.indexOf(_selectedYear);
                                _selectedYear =
                                    _years[(idx + 1) % _years.length];
                              }),
                              onDown: () => setState(() {
                                int idx = _years.indexOf(_selectedYear);
                                _selectedYear =
                                    _years[(idx - 1 + _years.length) % _years.length];
                              }),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Calculated Age Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: _isEligible
                              ? const Color(0xFFF0FDF4)
                              : const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _isEligible
                                ? const Color(0xFFBBF7D0)
                                : const Color(0xFFFECDD3),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isEligible
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.cancel_outlined,
                              size: 17,
                              color: _isEligible
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFE11D48),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Âge calculé : ",
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF475569),
                              ),
                            ),
                            Text(
                              "$age ans",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFE11D48),
                              ),
                            ),
                            Text(
                              _isEligible ? " (Éligible)" : " (Non éligible)",
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ---- CONFIRMATION CHECKBOX ----
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _confirmed,
                        activeColor: const Color(0xFF172554),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        side: const BorderSide(
                          color: Color(0xFF172554),
                          width: 1.8,
                        ),
                        onChanged: (val) =>
                            setState(() => _confirmed = val ?? false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Je confirme ma date de naissance et reconnais que l'essayage d'avatar 3D nécessite des mesures de silhouette.",
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF475569),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ---- BIOMETRIC PRIVACY CARD ----
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: const Color(0xFFF1F5F9), width: 1.2),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.lock_outline_rounded,
                            size: 20, color: Color(0xFF475569)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Protection de la vie privée biométrique",
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "Les dates de naissance sont chiffrées de bout en bout pour maintenir la conformité avec les normes d'essayage virtuel et ne sont jamais diffusées ni vendues.",
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ---- CONFIRM BUTTON ----
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _confirmed && _isEligible
                        ? () {
                    Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ConsentPrivacyScreen(),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF43F5E),
                      disabledBackgroundColor:
                          const Color(0xFFF43F5E).withValues(alpha: 0.5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Confirmer et continuer",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ---- FOOTER ----
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline_rounded,
                        size: 13, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 5),
                    Text(
                      "Chiffré avec AES-256 • ID : DK-AR-FIT-2024",
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateColumn({
    required String label,
    required String value,
    required VoidCallback onUp,
    required VoidCallback onDown,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onUp,
            child: const Icon(Icons.keyboard_arrow_up_rounded,
                size: 22, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 32,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          GestureDetector(
            onTap: onDown,
            child: const Icon(Icons.keyboard_arrow_down_rounded,
                size: 22, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

