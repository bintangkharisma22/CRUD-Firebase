import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biodata1/BiodataService.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Panggil model
  Biodataservice? service;

  // Variabel untuk menyimpan docId yang dipilih
  String? selectedDocId;

  // Controller untuk input fields
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final addressController = TextEditingController();

  // Jalan saat screen show
  @override
  void initState() {
    super.initState();
    // Initialize an instance of cloud firestore
    service = Biodataservice(FirebaseFirestore.instance);
  }

  // Fungsi untuk mengisi field input dengan data yang dipilih
  void _selectDataForUpdate(String docId, String name, String age, String address) {
    setState(() {
      selectedDocId = docId;
      nameController.text = name;
      ageController.text = age;
      addressController.text = address;
    });
  }

  // Fungsi untuk membersihkan input fields dan selectedDocId
  void _clearInputFields() {
    setState(() {
      selectedDocId = null;
      nameController.clear();
      ageController.clear();
      addressController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(hintText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(hintText: 'Address'),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  // Call 'Biodata' which returns a Stream
                  stream: service?.getBiodata(),
                  builder: (context, snapshot) {
                    // Check our connection (loading|error)
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error fetching data: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No documents found'));
                    }

                    // Get documents from the snapshot
                    final documents = snapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final data = documents[index].data() as Map<String, dynamic>;
                        final docId = documents[index].id; // Get document ID
                        final name = data['name'] ?? 'No Name';
                        final age = data['age'] ?? 'No Age';

                        return ListTile(
                          title: Text(name),
                          subtitle: Text(age),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // Fill input fields with selected data
                                  _selectDataForUpdate(docId, name, age, data['address'] ?? 'No Address');
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  // Hapus data yang dipilih
                                  await _deleteData(docId);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Get name, age, and address dari controller
          final name = nameController.text.trim();
          final age = ageController.text.trim();
          final address = addressController.text.trim();

          // Validasi input
          if (name.isEmpty || age.isEmpty || address.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please fill all fields')),
            );
            return;
          }

          // Jika selectedDocId tidak null, update data. Jika null, tambahkan data baru.
          try {
            if (selectedDocId != null) {
              // Update data yang sudah ada
              await service?.update(selectedDocId!, {'name': name, 'age': age, 'address': address});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data updated successfully')),
              );
            } else {
              // Tambahkan data baru
              await service?.add({'name': name, 'age': age, 'address': address});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data added successfully')),
              );
            }

            // Clear input fields setelah berhasil menambah/memperbarui data
            _clearInputFields();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save data: $e')),
            );
          }
        },
        child: const Icon(Icons.save), // Ubah ikon sesuai kebutuhan
      ),
    );
  }

  // Fungsi untuk menghapus data
  Future<void> _deleteData(String docId) async {
    try {
      await service?.delete(docId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete data: $e')),
      );
    }
  }
}