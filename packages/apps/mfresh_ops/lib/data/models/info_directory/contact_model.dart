class ContactModel {
  final String id;
  final String name;
  final String contactType;
  final String brand;
  final String company;
  final String mobile1;
  final String mobile2;
  final String services;   
  final String description; 
  final String workedOn;   
  final String location;
  final String department;
  final String designation;
  final String email;      
  final String weblinks;
  final String gstin;
  final String address;
  final String level;      
  final String attImage;   

  ContactModel({
    required this.id,
    this.name = '-',
    this.contactType = '-',
    this.brand = '-',
    this.company = '-',
    this.mobile1 = '-',
    this.mobile2 = '-',
    this.services = '-',
    this.description = '-',
    this.workedOn = '-',
    this.location = '-',
    this.department = '-',
    this.designation = '-',
    this.email = '-',
    this.weblinks = '-',
    this.gstin = '-',
    this.address = '-',
    this.level = '-',
    this.attImage = '-',
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    String s(dynamic v) => (v == null || v.toString().trim().isEmpty) ? '-' : v.toString().trim();
    return ContactModel(
      id: s(json['id']),
      name: s(json['name']),
      contactType: s(json['contact_type']),
      brand: s(json['brand']),
      company: s(json['company']),
      mobile1: s(json['mobile1']),
      mobile2: s(json['mobile2']),
      services: s(json['typeservice']),
      description: s(json['comment']),
      workedOn: s(json['project']),
      location: s(json['location']),
      department: s(json['department']),
      designation: s(json['designation']),
      email: s(json['email_id']),
      weblinks: s(json['weblinks']),
      gstin: s(json['gstin']),
      address: s(json['address']),
      level: s(json['level_of'] ?? json['level']),
      attImage: s(json['att_image']),
    );
  }
}
