import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/order_model.dart';
import '../../../core/repositories/order_repository.dart';
import '../../scan/widgets/deposit_method_modal.dart';
import '../models/history_item_model.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/filter_chip_widget.dart';
import '../widgets/history_card.dart';
import '../widgets/ongoing_card.dart';
import '../widgets/segmented_tab.dart';
import '../widgets/transaction_card.dart';

class OrdersScreen extends StatefulWidget {
  final dynamic newOrder;
  final int initialTabIndex;

  const OrdersScreen({super.key, this.newOrder, this.initialTabIndex = 0});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _repository = OrderRepository.instance;

  /// 0 = Ongoing (default), 1 = History
  late int _selectedTab;
  HistoryFilter _selectedFilter = HistoryFilter.semua;

  List<HistoryItemModel> _allHistory = [];
  List<dynamic> _ongoingOrders = [];
  bool _isLoadingHistory = true;
  bool _isLoadingOngoing = true;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTabIndex.clamp(0, 1);

    _loadHistory();
    _loadOngoing();

    if (widget.newOrder is OrderModel) {
      _repository.addOrder(widget.newOrder as OrderModel);
      _selectedTab = 0; // Override to Ongoing when new order arrives
    }
  }

  Future<void> _loadHistory() async {
    try {
      final items = await _repository.getHistoryItems();
      if (mounted) {
        setState(() {
          _allHistory = items
              .where((item) =>
                  item.type == HistoryType.setor ||
                  item.type == HistoryType.pencairan)
              .toList();
          _isLoadingHistory = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    }
  }

  Future<void> _loadOngoing() async {
    try {
      final items = await _repository.getOngoingOrders();
      if (mounted) {
        setState(() {
          _ongoingOrders = items;
          _isLoadingOngoing = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingOngoing = false;
        });
      }
    }
  }

  List<HistoryItemModel> get _filteredHistory {
    final type = _selectedFilter.typeFilter;
    if (type == null) return _allHistory;
    return _allHistory.where((item) => item.type == type).toList();
  }

  String get _appBarTitle => _selectedTab == 0 ? 'Order' : 'Riwayat';

  @override
  Widget build(BuildContext context) {
    final ongoing = _ongoingOrders;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              bottom: BorderSide(color: AppColors.border, width: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            top: true,
            bottom: false,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.15),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  _appBarTitle,
                  key: ValueKey(_appBarTitle),
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedTabWidget(
                selectedIndex: _selectedTab,
                onChanged: (index) => setState(() => _selectedTab = index),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedTab == 1) _buildFilterChips(),
          if (_selectedTab == 1) const SizedBox(height: 12),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.02),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _selectedTab == 0
                  ? _buildOngoingTab(ongoing)
                  : _buildHistoryTab(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    // Only show relevant filters (semua, setor, pencairan)
    const relevantFilters = [
      HistoryFilter.semua,
      HistoryFilter.setorSampah,
      HistoryFilter.pencairanSaldo,
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: relevantFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 0),
        itemBuilder: (context, index) {
          final filter = relevantFilters[index];
          return FilterChipWidget(
            label: filter.label,
            isSelected: _selectedFilter == filter,
            onTap: () => setState(() => _selectedFilter = filter),
          );
        },
      ),
    );
  }

  Widget _buildOngoingTab(List ongoing) {
    if (ongoing.isEmpty) {
      return EmptyStateWidget.ongoing(
        key: const ValueKey('ongoing-empty'),
        onStartDeposit: () => DepositMethodModal.show(context),
      );
    }

    return ListView.builder(
      key: const ValueKey('ongoing-list'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: ongoing.length,
      itemBuilder: (context, index) => OngoingCard(
        order: ongoing[index],
        onRefresh: _loadOngoing,
      ),
    );
  }

  Widget _buildHistoryTab() {
    final items = _filteredHistory;

    if (items.isEmpty) {
      return EmptyStateWidget.filter(
        key: ValueKey('history-empty-${_selectedFilter.name}'),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOut,
      child: ListView.builder(
        key: ValueKey(_selectedFilter.name),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          if (item.type == HistoryType.setor) {
            return HistoryCard(item: item);
          }
          return TransactionCard(item: item);
        },
      ),
    );
  }
}
