import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/reminder_model.dart';

class ReminderCard extends StatefulWidget {
  final ReminderModel reminder;
  final Function(String) onStatusChanged;
  final VoidCallback onDelete;

  const ReminderCard({
    Key? key,
    required this.reminder,
    required this.onStatusChanged,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends State<ReminderCard>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    if (widget.reminder.isOverdue) {
      return Colors.red;
    } else if (widget.reminder.isUpcoming) {
      return Colors.orange;
    } else if (widget.reminder.isCompleted) {
      return Colors.green;
    } else if (widget.reminder.isActive) {
      return Colors.blue;
    } else {
      return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    if (widget.reminder.isOverdue) {
      return Icons.warning;
    } else if (widget.reminder.isUpcoming) {
      return Icons.schedule;
    } else if (widget.reminder.isCompleted) {
      return Icons.check_circle;
    } else if (widget.reminder.isActive) {
      return Icons.alarm;
    } else {
      return Icons.cancel;
    }
  }

  String _getStatusText() {
    if (widget.reminder.isOverdue) {
      return 'Overdue';
    } else if (widget.reminder.isUpcoming) {
      return 'Upcoming';
    } else if (widget.reminder.isCompleted) {
      return 'Completed';
    } else if (widget.reminder.isActive) {
      return 'Active';
    } else {
      return 'Cancelled';
    }
  }

  void _showActionMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Reminder Actions',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            // Actions
            if (widget.reminder.isActive) ...[
              _buildActionTile(
                icon: Icons.check_circle,
                title: 'Mark as Completed',
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  widget.onStatusChanged('completed');
                },
              ),
              _buildActionTile(
                icon: Icons.cancel,
                title: 'Cancel Reminder',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  widget.onStatusChanged('cancelled');
                },
              ),
            ],
            
            if (widget.reminder.isCompleted || widget.reminder.isCancelled) ...[
              _buildActionTile(
                icon: Icons.restart_alt,
                title: 'Reactivate',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  widget.onStatusChanged('active');
                },
              ),
            ],
            
            _buildActionTile(
              icon: Icons.delete,
              title: 'Delete Reminder',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation();
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(
          'Delete Reminder',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this reminder? This action cannot be undone.',
          style: GoogleFonts.inter(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            child: Text(
              'Delete',
              style: GoogleFonts.inter(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      onLongPress: _showActionMenu,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getStatusColor().withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getStatusColor().withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Main Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row
                        Row(
                          children: [
                            // Status Icon
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getStatusColor().withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getStatusIcon(),
                                color: _getStatusColor(),
                                size: 20,
                              ),
                            ),
                            
                            const SizedBox(width: 12),
                            
                            // Event Name
                            Expanded(
                              child: Text(
                                widget.reminder.eventName,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                            // Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor().withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor().withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                _getStatusText(),
                                style: GoogleFonts.inter(
                                  color: _getStatusColor(),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Time Info
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.white60,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.reminder.formattedDateTime,
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              widget.reminder.formattedReminderTime,
                              style: GoogleFonts.inter(
                                color: widget.reminder.isOverdue 
                                    ? Colors.red 
                                    : Colors.white60,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Expanded Details
                  if (_isExpanded) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.02),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Lead Time Info
                          if (widget.reminder.leadTimeDays > 0 ||
                              widget.reminder.leadTimeMinutes > 0 ||
                              widget.reminder.leadTimeSeconds > 0) ...[
                            Text(
                              'Lead Time:',
                              style: GoogleFonts.inter(
                                color: Colors.white60,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatLeadTime(),
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          
                          // Created Date
                          Text(
                            'Created: ${_formatDate(widget.reminder.createdAt)}',
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Action Buttons
                          Row(
                            children: [
                              if (widget.reminder.isActive) ...[
                                _buildActionButton(
                                  icon: Icons.check,
                                  label: 'Complete',
                                  color: Colors.green,
                                  onTap: () => widget.onStatusChanged('completed'),
                                ),
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  icon: Icons.cancel,
                                  label: 'Cancel',
                                  color: Colors.orange,
                                  onTap: () => widget.onStatusChanged('cancelled'),
                                ),
                              ] else ...[
                                _buildActionButton(
                                  icon: Icons.restart_alt,
                                  label: 'Reactivate',
                                  color: Colors.blue,
                                  onTap: () => widget.onStatusChanged('active'),
                                ),
                              ],
                              const Spacer(),
                              _buildActionButton(
                                icon: Icons.delete,
                                label: 'Delete',
                                color: Colors.red,
                                onTap: _showDeleteConfirmation,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLeadTime() {
    List<String> parts = [];
    
    if (widget.reminder.leadTimeDays > 0) {
      parts.add('${widget.reminder.leadTimeDays} day${widget.reminder.leadTimeDays > 1 ? 's' : ''}');
    }
    
    if (widget.reminder.leadTimeMinutes > 0) {
      parts.add('${widget.reminder.leadTimeMinutes} minute${widget.reminder.leadTimeMinutes > 1 ? 's' : ''}');
    }
    
    if (widget.reminder.leadTimeSeconds > 0) {
      parts.add('${widget.reminder.leadTimeSeconds} second${widget.reminder.leadTimeSeconds > 1 ? 's' : ''}');
    }
    
    return parts.join(', ');
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return '$day/$month/$year at $hour:$minute';
  }
}
