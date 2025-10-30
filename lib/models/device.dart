class Device {
  final int id;
  final int? parentId;
  final String uuid;
  final int? updated;
  final String name;
  final int type;
  final int pid;
  final int source;
  final int opt;
  final int? counter;
  final int counterType;
  final int addr;

  Device({
    required this.id,
    this.parentId,
    required this.uuid,
    this.updated,
    required this.name,
    required this.type,
    required this.pid,
    required this.source,
    required this.opt,
    this.counter,
    required this.counterType,
    required this.addr,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: _parseInt(json['id']) ?? 0,
      parentId: json['parent_id'] != null ? _parseInt(json['parent_id']) : null,
      uuid: json['uuid']?.toString() ?? '',
      updated: json['updated'] != null ? _parseInt(json['updated']) : null,
      name: json['name']?.toString() ?? '',
      type: _parseInt(json['type']) ?? 0,
      pid: _parseInt(json['pid']) ?? 0,
      source: _parseInt(json['source']) ?? 0,
      opt: _parseInt(json['opt']) ?? 0,
      counter: json['counter'] != null ? _parseInt(json['counter']) : null,
      counterType: _parseInt(json['counterType']) ?? 0,
      addr: _parseInt(json['addr']) ?? 0,
    );
  }

  // Helper pour convertir les valeurs en int (gère String et int)
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_id': parentId,
      'uuid': uuid,
      'updated': updated,
      'name': name,
      'type': type,
      'pid': pid,
      'source': source,
      'opt': opt,
      'counter': counter,
      'counterType': counterType,
      'addr': addr,
    };
  }
}
