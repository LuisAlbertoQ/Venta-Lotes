import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ListarVentasScreen extends StatefulWidget {
  final String token;
  const ListarVentasScreen({Key? key, required this.token}) : super(key: key);

  @override
  _ListarVentasScreenState createState() => _ListarVentasScreenState();
}

class _ListarVentasScreenState extends State<ListarVentasScreen> {
  List<dynamic> ventas = [];
  List<dynamic> filteredVentas = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchVentas();
  }

  Future<void> fetchVentas() async {
    final url = Uri.parse('http://10.0.2.2:8000/listar-ventas/');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        ventas = jsonDecode(response.body);
        filteredVentas = ventas;
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al obtener ventas'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterVentas(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredVentas = ventas.where((venta) {
        final compradorId = venta['id_comprador'].toString().toLowerCase();
        final loteId = venta['id_lote'].toString().toLowerCase();
        return compradorId.contains(searchQuery) || loteId.contains(searchQuery);
      }).toList();
    });
  }

  Widget _buildVentaItem(Map<String, dynamic> venta) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.receipt_long,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Venta #${venta['id']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Lote: ${venta['id_lote']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  Icons.person,
                  'Comprador ID',
                  venta['id_comprador'].toString(),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.attach_money,
                  'Precio',
                  '\$${venta['precio_venta']}',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.description,
                  'Condiciones',
                  venta['condiciones'] ?? 'No especificado',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Lista de Ventas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Buscar por ID de Comprador o Lote',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: const Icon(Icons.filter_list),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: _filterVentas,
              ),
            ),
            Expanded(
              child: filteredVentas.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay ventas que coincidan\ncon la búsqueda',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: filteredVentas.length,
                itemBuilder: (context, index) {
                  return _buildVentaItem(filteredVentas[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}