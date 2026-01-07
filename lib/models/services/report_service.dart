import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rechoice_app/models/services/firestore_service.dart';

class ReportService {
  final FirestoreService _firestoreService;
  
  ReportService(this._firestoreService);

  CollectionReference get _reportsCollection =>
      _firestoreService.firestoreInstance.collection('reports');

  Future<String?> createReport({
    required int reporterID,
    required String reporterName,
    required int reportedSellerID,
    required String reportedSellerName,
    required int itemID,
    required String productName,
    required String orderId,
    required String reason,
    required String details,
    String? reviewId,
  }) async {
    try {
      final report = {
        'reporterID': reporterID,
        'reporterName': reporterName,
        'reportedSellerID': reportedSellerID,
        'reportedSellerName': reportedSellerName,
        'itemID': itemID,
        'productName': productName,
        'orderId': orderId,
        'reason': reason,
        'details': details,
        'reviewId': reviewId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'resolvedAt': null,
        'resolvedBy': null,
        'resolution': null,
      };

      final docRef = await _reportsCollection.add(report);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create report: $e');
    }
  }

  Future<void> updateReportStatus({
    required String reportId,
    required String status,
    int? resolvedBy,
    String? resolution,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
      };

      if (status == 'resolved') {
        updates['resolvedAt'] = FieldValue.serverTimestamp();
        if (resolvedBy != null) updates['resolvedBy'] = resolvedBy;
        if (resolution != null) updates['resolution'] = resolution;
      }

      await _reportsCollection.doc(reportId).update(updates);
    } catch (e) {
      throw Exception('Failed to update report status: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getReportsByUser(int userId) async {
    try {
      final snapshot = await _reportsCollection
          .where('reporterID', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to get reports: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPendingReports() async {
    try {
      final snapshot = await _reportsCollection
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to get pending reports: $e');
    }
  }
}