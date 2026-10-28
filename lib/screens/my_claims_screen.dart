import 'package:flutter/material.dart';
import '../models/item_claim.dart';
import '../services/auth_service.dart';
import '../services/claim_service.dart';

class MyClaimsScreen extends StatelessWidget {
  MyClaimsScreen({super.key});

  final ClaimService _claimService = ClaimService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in.')));
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Claims Management'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Sent Claims'),
              Tab(text: 'Received Requests'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildClaimList(_claimService.getClaimsForUser(user.uid), isReceived: false),
            _buildClaimList(_claimService.getClaimsForOwnerItems(user.uid), isReceived: true),
          ],
        ),
      ),
    );
  }

  Widget _buildClaimList(Stream<List<ItemClaim>> stream, {required bool isReceived}) {
    return StreamBuilder<List<ItemClaim>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              isReceived ? 'No claim requests received yet.' : 'You have not submitted any claims.',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        final claims = snapshot.data!;

        return ListView.builder(
          itemCount: claims.length,
          itemBuilder: (context, index) {
            final claim = claims[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text('Claim Status: ${claim.status}'),
                subtitle: Text('Message: "${claim.message}"'),
                trailing: isReceived && claim.status == 'Pending'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () => _claimService.updateClaimStatus(claim.claimId, 'Accepted'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => _claimService.updateClaimStatus(claim.claimId, 'Rejected'),
                          ),
                        ],
                      )
                    : Chip(
                        label: Text(claim.status),
                        backgroundColor: claim.status == 'Accepted' ? Colors.green[100] : Colors.grey[200],
                      ),
              ),
            );
          },
        );
      },
    );
  }
}