// // widgets/reusable_data_table.dart
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:k2k/utils/sreen_util.dart';
// import 'package:k2k/utils/theme.dart';

// class TableColumn {
//   final String key;
//   final String label;
//   final double? width;
//   final bool sortable;
//   final bool numeric;
//   final bool visible;
//   final Widget Function(dynamic value)? customWidget;

//   TableColumn({
//     required this.key,
//     required this.label,
//     this.width,a
//     this.sortable = false,
//     this.numeric = false,
//     this.visible = true,
//     this.customWidget,
//   });
// }

// class TableAction {
//   final String label;
//   final IconData icon;
//   final Color? color;
//   final VoidCallback onTap;

//   TableAction({
//     required this.label,
//     required this.icon,
//     this.color,
//     required this.onTap,
//   });
// }

// class ReusableDataTable extends StatefulWidget {
//   final List<Map<String, dynamic>> data;
//   final List<TableColumn> columns;
//   final List<TableAction> Function(Map<String, dynamic> item)? actions;
//   final bool showSerialNumber;
//   final bool isLoading;
//   final String? emptyMessage;
//   final VoidCallback? onRefresh;
//   final VoidCallback? onLoadMore;
//   final bool hasMore;
//   final int currentPage;
//   final int totalCount;
//   final String? title;

//   const ReusableDataTable({
//     super.key,
//     required this.data,
//     required this.columns,
//     this.actions,
//     this.showSerialNumber = true,
//     this.isLoading = false,
//     this.emptyMessage = 'No data available',
//     this.onRefresh,
//     this.onLoadMore,
//     this.hasMore = false,
//     this.currentPage = 1,
//     this.totalCount = 0,
 
//     this.title,
//   });

//   @override
//   State<ReusableDataTable> createState() => _ReusableDataTableState();
// }

// class _ReusableDataTableState extends State<ReusableDataTable> {
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_onScroll);
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _onScroll() {
//     if (_scrollController.position.pixels >= 
//         _scrollController.position.maxScrollExtent - 200) {
//       if (widget.hasMore && !widget.isLoading) {
//         widget.onLoadMore?.call();
//       }
//     }
//   }

//   List<TableColumn> get visibleColumns {
//     return widget.columns.where((col) => col.visible).toList();
//   }


//   Widget _buildHeader() {
//     return Container(
//       height: ScreenUtil.tableHeaderHeight,
//       padding: EdgeInsets.symmetric(
//         horizontal: ScreenUtil.spacingMedium,
//         vertical: ScreenUtil.spacingSmall,
//       ),
//       decoration: BoxDecoration(
//         gradient: AppTheme.primaryGradient,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(ScreenUtil.borderRadiusLarge),
//           topRight: Radius.circular(ScreenUtil.borderRadiusLarge),
//         ),
//       ),
//       child: Row(
//         children: [
//           if (widget.showSerialNumber)
//             SizedBox(
//               width: ScreenUtil.isMobile ? 50 : 60,
//               child: Text(
//                 'S.No',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                   fontSize: ScreenUtil.textSizeMedium,
//                 ),
//               ),
//             ),
//           ...visibleColumns.map((column) {
//             return Expanded(
//               flex: column.width?.toInt() ?? 1,
//               child: Text(
//                 column.label,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                   fontSize: ScreenUtil.textSizeMedium,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             );
//           }),
//           if (widget.actions != null)
//             SizedBox(
//               width: ScreenUtil.isMobile ? 80 : 120,
//               child: Text(
//                 'Actions',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                   fontSize: ScreenUtil.textSizeMedium,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDataRow(Map<String, dynamic> item, int index) {
//     final serialNumber = (widget.currentPage - 1) * 10 + index + 1;
    
//     return Container(
//       height: ScreenUtil.tableRowHeight,
//       padding: EdgeInsets.symmetric(
//         horizontal: ScreenUtil.spacingMedium,
//         vertical: ScreenUtil.spacingSmall,
//       ),
//       decoration: BoxDecoration(
//         color: index % 2 == 0 ? Colors.white : AppTheme.lightGray,
//         border: const Border(
//           bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
//         ),
//       ),
//       child: Row(
//         children: [
//           if (widget.showSerialNumber)
//             SizedBox(
//               width: ScreenUtil.isMobile ? 50 : 60,
//               child: Text(
//                 serialNumber.toString(),
//                 style: TextStyle(
//                   fontSize: ScreenUtil.textSizeMedium,
//                   color: AppTheme.darkGray,
//                 ),
//               ),
//             ),
//           ...visibleColumns.map((column) {
//             final value = item[column.key];
//             return Expanded(
//               flex: column.width?.toInt() ?? 1,
//               child: column.customWidget?.call(value) ?? _buildCellContent(value, column),
//             );
//           }),
//           if (widget.actions != null)
//             SizedBox(
//               width: ScreenUtil.isMobile ? 80 : 120,
//               child: _buildActionButtons(item),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButtons(Map<String, dynamic> item) {
//     final actions = widget.actions!(item);
    
//     if (ScreenUtil.isMobile) {
//       // On mobile, show only first action and a menu for others
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           if (actions.isNotEmpty)
//             IconButton(
//               onPressed: actions.first.onTap,
//               icon: Icon(
//                 actions.first.icon,
//                 size: ScreenUtil.iconSizeSmall,
//                 color: actions.first.color ?? AppTheme.primaryBlue,
//               ),
//               tooltip: actions.first.label,
//             ),
//           if (actions.length > 1)
//             PopupMenuButton<TableAction>(
//               onSelected: (action) => action.onTap(),
//               itemBuilder: (context) => actions.skip(1).map((action) {
//                 return PopupMenuItem<TableAction>(
//                   value: action,
//                   child: Row(
//                     children: [
//                       Icon(action.icon, size: ScreenUtil.iconSizeSmall),
//                       SizedBox(width: ScreenUtil.spacingSmall),
//                       Text(action.label),
//                     ],
//                   ),
//                 );
//               }).toList(),
//               icon: Icon(Icons.more_vert, size: ScreenUtil.iconSizeSmall),
//             ),
//         ],
//       );
//     } else {
//       // On tablet/desktop, show all actions
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: actions.map((action) {
//           return Tooltip(
//             message: action.label,
//             child: InkWell(
//               onTap: action.onTap,
//               borderRadius: BorderRadius.circular(ScreenUtil.borderRadiusSmall),
//               child: Padding(
//                 padding: EdgeInsets.all(ScreenUtil.spacingSmall),
//                 child: Icon(
//                   action.icon,
//                   size: ScreenUtil.iconSizeSmall,
//                   color: action.color ?? AppTheme.primaryBlue,
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       );
//     }
//   }

//   Widget _buildCellContent(dynamic value, TableColumn column) {
//     String displayValue = '';
    
//     if (value == null) {
//       displayValue = '-';
//     } else if (value is DateTime) {
//       displayValue = DateFormat('dd/MM/yyyy HH:mm').format(value);
//     } else if (value is Map && value.containsKey('username')) {
//       displayValue = value['username'] ?? '-';
//     } else {
//       displayValue = value.toString();
//     }

//     return Text(
//       displayValue,
//       style: TextStyle(
//         fontSize: ScreenUtil.textSizeMedium,
//         color: AppTheme.darkGray,
//       ),
//       overflow: TextOverflow.ellipsis,
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.inbox_outlined,
//             size: ScreenUtil.isMobile ? 48 : 64,
//             color: AppTheme.mediumGray,
//           ),
//           SizedBox(height: ScreenUtil.spacingMedium),
//           Text(
//             widget.emptyMessage!,
//             style: TextStyle(
//               fontSize: ScreenUtil.textSizeLarge,
//               color: AppTheme.mediumGray,
//             ),
//           ),
//           SizedBox(height: ScreenUtil.spacingMedium),
//           if (widget.onRefresh != null)
//             ElevatedButton(
//               onPressed: widget.onRefresh,
//               child: const Text('Refresh'),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoadingIndicator() {
//     return Center(
//       child: Padding(
//         padding: ScreenUtil.defaultPadding,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const CircularProgressIndicator(),
//             SizedBox(height: ScreenUtil.spacingMedium),
//             Text(
//               'Loading...',
//               style: TextStyle(
//                 fontSize: ScreenUtil.textSizeMedium,
//                 color: AppTheme.mediumGray,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFooter() {
//     return Container(
//       padding: ScreenUtil.defaultPadding,
//       decoration: BoxDecoration(
//         color: AppTheme.lightGray,
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(ScreenUtil.borderRadiusLarge),
//           bottomRight: Radius.circular(ScreenUtil.borderRadiusLarge),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Total: ${widget.totalCount} items',
//             style: TextStyle(
//               fontSize: ScreenUtil.textSizeMedium,
//               color: AppTheme.mediumGray,
//             ),
//           ),
//           Text(
//             'Page ${widget.currentPage}',
//             style: TextStyle(
//               fontSize: ScreenUtil.textSizeMedium,
//               color: AppTheme.mediumGray,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     ScreenUtil.init(context);
    
//     return Scaffold(
//       backgroundColor: AppTheme.lightGray,
//       body: Column(
//         children: [
//           Expanded(
//             child: Container(
//               margin: ScreenUtil.defaultPadding,
//               constraints: BoxConstraints(
//                 maxWidth: ScreenUtil.containerMaxWidth,
//               ),
//               child: Card(
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(ScreenUtil.borderRadiusLarge),
//                 ),
//                 child: Column(
//                   children: [
//                     _buildHeader(),
//                     Expanded(
//                       child: widget.data.isEmpty && !widget.isLoading
//                           ? _buildEmptyState()
//                           : ListView.builder(
//                               controller: _scrollController,
//                               itemCount: widget.data.length + (widget.hasMore ? 1 : 0),
//                               itemBuilder: (context, index) {
//                                 if (index < widget.data.length) {
//                                   return _buildDataRow(widget.data[index], index);
//                                 } else {
//                                   return _buildLoadingIndicator();
//                                 }
//                               },
//                             ),
//                     ),
//                     if (widget.data.isNotEmpty) _buildFooter(),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }