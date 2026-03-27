// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderAdapter extends TypeAdapter<Order> {
  @override
  final int typeId = 1;

  @override
  Order read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Order(
      id: fields[0] as String,
      customerId: fields[1] as String,
      customerName: fields[2] as String,
      product: fields[3] as String,
      price: fields[4] as double,
      amountPaid: fields[5] as double,
      status: fields[6] as String,
      createdAt: fields[7] as DateTime,
      notes: fields[8] as String?,
      expectedDeliveryDate: fields[9] as DateTime?,
      paidAt: fields[10] as DateTime?,
      dispatchedAt: fields[11] as DateTime?,
      deliveredAt: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Order obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.customerName)
      ..writeByte(3)
      ..write(obj.product)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.amountPaid)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.expectedDeliveryDate)
      ..writeByte(10)
      ..write(obj.paidAt)
      ..writeByte(11)
      ..write(obj.dispatchedAt)
      ..writeByte(12)
      ..write(obj.deliveredAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
