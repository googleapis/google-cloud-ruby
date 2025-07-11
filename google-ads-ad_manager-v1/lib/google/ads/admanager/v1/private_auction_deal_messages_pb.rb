# frozen_string_literal: true
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: google/ads/admanager/v1/private_auction_deal_messages.proto

require 'google/protobuf'

require 'google/ads/admanager/v1/deal_buyer_permission_type_enum_pb'
require 'google/ads/admanager/v1/private_marketplace_enums_pb'
require 'google/ads/admanager/v1/size_pb'
require 'google/ads/admanager/v1/targeting_pb'
require 'google/api/field_behavior_pb'
require 'google/api/resource_pb'
require 'google/protobuf/timestamp_pb'
require 'google/type/money_pb'


descriptor_data = "\n;google/ads/admanager/v1/private_auction_deal_messages.proto\x12\x17google.ads.admanager.v1\x1a=google/ads/admanager/v1/deal_buyer_permission_type_enum.proto\x1a\x37google/ads/admanager/v1/private_marketplace_enums.proto\x1a\"google/ads/admanager/v1/size.proto\x1a\'google/ads/admanager/v1/targeting.proto\x1a\x1fgoogle/api/field_behavior.proto\x1a\x19google/api/resource.proto\x1a\x1fgoogle/protobuf/timestamp.proto\x1a\x17google/type/money.proto\"\xe0\x0b\n\x12PrivateAuctionDeal\x12\x11\n\x04name\x18\x01 \x01(\tB\x03\xe0\x41\x08\x12)\n\x17private_auction_deal_id\x18\x02 \x01(\x03\x42\x03\xe0\x41\x03H\x00\x88\x01\x01\x12$\n\x12private_auction_id\x18\x03 \x01(\x03\x42\x03\xe0\x41\x05H\x01\x88\x01\x01\x12.\n\x1cprivate_auction_display_name\x18\x14 \x01(\tB\x03\xe0\x41\x03H\x02\x88\x01\x01\x12\"\n\x10\x62uyer_account_id\x18\x04 \x01(\x03\x42\x03\xe0\x41\x05H\x03\x88\x01\x01\x12\"\n\x10\x65xternal_deal_id\x18\x05 \x01(\x03\x42\x03\xe0\x41\x03H\x04\x88\x01\x01\x12?\n\ttargeting\x18\x06 \x01(\x0b\x32\".google.ads.admanager.v1.TargetingB\x03\xe0\x41\x01H\x05\x88\x01\x01\x12\x36\n\x08\x65nd_time\x18\x08 \x01(\x0b\x32\x1a.google.protobuf.TimestampB\x03\xe0\x41\x01H\x06\x88\x01\x01\x12\x31\n\x0b\x66loor_price\x18\t \x01(\x0b\x32\x12.google.type.MoneyB\x03\xe0\x41\x02H\x07\x88\x01\x01\x12:\n\x0e\x63reative_sizes\x18\x12 \x03(\x0b\x32\x1d.google.ads.admanager.v1.SizeB\x03\xe0\x41\x01\x12p\n\x06status\x18\n \x01(\x0e\x32V.google.ads.admanager.v1.PrivateMarketplaceDealStatusEnum.PrivateMarketplaceDealStatusB\x03\xe0\x41\x03H\x08\x88\x01\x01\x12*\n\x18\x61uction_priority_enabled\x18\x0b \x01(\x08\x42\x03\xe0\x41\x01H\t\x88\x01\x01\x12(\n\x16\x62lock_override_enabled\x18\x0c \x01(\x08\x42\x03\xe0\x41\x01H\n\x88\x01\x01\x12u\n\x15\x62uyer_permission_type\x18\r \x01(\x0e\x32L.google.ads.admanager.v1.DealBuyerPermissionTypeEnum.DealBuyerPermissionTypeB\x03\xe0\x41\x01H\x0b\x88\x01\x01\x12S\n\nbuyer_data\x18\x0e \x01(\x0b\x32\x35.google.ads.admanager.v1.PrivateAuctionDeal.BuyerDataB\x03\xe0\x41\x01H\x0c\x88\x01\x01\x12\x39\n\x0b\x63reate_time\x18\x0f \x01(\x0b\x32\x1a.google.protobuf.TimestampB\x03\xe0\x41\x03H\r\x88\x01\x01\x12\x39\n\x0bupdate_time\x18\x10 \x01(\x0b\x32\x1a.google.protobuf.TimestampB\x03\xe0\x41\x03H\x0e\x88\x01\x01\x1a&\n\tBuyerData\x12\x19\n\x0c\x62uyer_emails\x18\x01 \x03(\tB\x03\xe0\x41\x01:\x9e\x01\xea\x41\x9a\x01\n+admanager.googleapis.com/PrivateAuctionDeal\x12\x42networks/{network_code}/privateAuctionDeals/{private_auction_deal}*\x13privateAuctionDeals2\x12privateAuctionDealB\x1a\n\x18_private_auction_deal_idB\x15\n\x13_private_auction_idB\x1f\n\x1d_private_auction_display_nameB\x13\n\x11_buyer_account_idB\x13\n\x11_external_deal_idB\x0c\n\n_targetingB\x0b\n\t_end_timeB\x0e\n\x0c_floor_priceB\t\n\x07_statusB\x1b\n\x19_auction_priority_enabledB\x19\n\x17_block_override_enabledB\x18\n\x16_buyer_permission_typeB\r\n\x0b_buyer_dataB\x0e\n\x0c_create_timeB\x0e\n\x0c_update_timeB\xd3\x01\n\x1b\x63om.google.ads.admanager.v1B\x1fPrivateAuctionDealMessagesProtoP\x01Z@google.golang.org/genproto/googleapis/ads/admanager/v1;admanager\xaa\x02\x17Google.Ads.AdManager.V1\xca\x02\x17Google\\Ads\\AdManager\\V1\xea\x02\x1aGoogle::Ads::AdManager::V1b\x06proto3"

pool = Google::Protobuf::DescriptorPool.generated_pool

begin
  pool.add_serialized_file(descriptor_data)
rescue TypeError
  # Compatibility code: will be removed in the next major version.
  require 'google/protobuf/descriptor_pb'
  parsed = Google::Protobuf::FileDescriptorProto.decode(descriptor_data)
  parsed.clear_dependency
  serialized = parsed.class.encode(parsed)
  file = pool.add_serialized_file(serialized)
  warn "Warning: Protobuf detected an import path issue while loading generated file #{__FILE__}"
  imports = [
    ["google.ads.admanager.v1.Targeting", "google/ads/admanager/v1/targeting.proto"],
    ["google.protobuf.Timestamp", "google/protobuf/timestamp.proto"],
    ["google.type.Money", "google/type/money.proto"],
    ["google.ads.admanager.v1.Size", "google/ads/admanager/v1/size.proto"],
  ]
  imports.each do |type_name, expected_filename|
    import_file = pool.lookup(type_name).file_descriptor
    if import_file.name != expected_filename
      warn "- #{file.name} imports #{expected_filename}, but that import was loaded as #{import_file.name}"
    end
  end
  warn "Each proto file must use a consistent fully-qualified name."
  warn "This will become an error in the next major version."
end

module Google
  module Ads
    module AdManager
      module V1
        PrivateAuctionDeal = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.ads.admanager.v1.PrivateAuctionDeal").msgclass
        PrivateAuctionDeal::BuyerData = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.ads.admanager.v1.PrivateAuctionDeal.BuyerData").msgclass
      end
    end
  end
end
