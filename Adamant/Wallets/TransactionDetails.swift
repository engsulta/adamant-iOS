//
//  TransactionDetailsProtocol.swift
//  Adamant
//
//  Created by Anton Boyarkin on 26/06/2018.
//  Copyright © 2018 Adamant. All rights reserved.
//

import Foundation
import web3swift
import BigInt

/// A standard protocol representing a Transaction details.
protocol TransactionDetails {
    /// The identifier of the transaction.
    var txId: String { get }
    
    /// The sender of the transaction.
    var senderAddress: String { get }
    
    /// The reciver of the transaction.
    var recipientAddress: String { get }
    
    /// The date the transaction was sent.
    var dateValue: Date? { get }
    
    /// The amount of currency that was sent.
    var amountValue: Decimal { get }
    
    /// The amount of fee that taken for transaction process.
    var feeValue: Decimal? { get }
    
    /// The confirmations of the transaction.
    var confirmationsValue: String? { get }
    
    /// The block of the transaction.
    var blockValue: String? { get }
    
    var isOutgoing: Bool { get }
    
    var transactionStatus: TransactionStatus? { get }
}

extension TransactionDetails {
//    func getSummary() -> String {
//        return """
//        Transaction #\(id)
//
//        Summary
//        Sender: \(senderAddress)
//        Recipient: \(recipientAddress)
//        Date: \(DateFormatter.localizedString(from: sentDate, dateStyle: .short, timeStyle: .medium))
//        Amount: \(formattedAmount())
//        Fee: \(formattedFee())
//        Confirmations: \(String(confirmationsValue))
//        Block: \(block)
//        URL: \(explorerUrl?.absoluteString ?? "")
//        """
//    }
}
