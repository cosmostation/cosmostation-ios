//
//  SuiTransactionMapper.swift
//  Cosmostation
//
//  Created by 권혁준 on 9/22/26.
//  Copyright © 2026 wannabit. All rights reserved.
//

import Foundation
import SwiftyJSON

func mapProgrammableTransactionKind(_ txJson: JSON) -> Sui_Rpc_V2_TransactionKind {
    return Sui_Rpc_V2_TransactionKind.with {
        $0.kind = .programmableTransaction
        $0.programmableTransaction = Sui_Rpc_V2_ProgrammableTransaction.with {
            $0.inputs = txJson["inputs"].arrayValue.map { mapSuiInput($0) }
            $0.commands = txJson["commands"].arrayValue.map { mapSuiCommand($0) }
        }
    }
}

private func mapSuiInput(_ input: JSON) -> Sui_Rpc_V2_Input {
    var result = Sui_Rpc_V2_Input()

    if (input["Pure"].exists()) {
        result.kind = .pure
        result.pure = Data(base64Encoded: input["Pure"]["bytes"].stringValue) ?? Data()

    } else if (input["UnresolvedObject"].exists()) {
        let object = input["UnresolvedObject"]
        result.objectID = object["objectId"].stringValue
        if let version = UInt64(object["version"].stringValue) { result.version = version }
        if let digest = object["digest"].string { result.digest = digest }
        if let initialSharedVersion = UInt64(object["initialSharedVersion"].stringValue) {
            result.kind = .shared
            result.version = initialSharedVersion
        }

    } else if (input["Object"]["ImmOrOwnedObject"].exists()) {
        let object = input["Object"]["ImmOrOwnedObject"]
        result.kind = .immutableOrOwned
        result.objectID = object["objectId"].stringValue
        result.version = UInt64(object["version"].stringValue) ?? 0
        result.digest = object["digest"].stringValue

    } else if (input["Object"]["SharedObject"].exists()) {
        let object = input["Object"]["SharedObject"]
        result.kind = .shared
        result.objectID = object["objectId"].stringValue
        result.version = UInt64(object["initialSharedVersion"].stringValue) ?? 0
        result.mutable = object["mutable"].boolValue

    } else if (input["Object"]["Receiving"].exists()) {
        let object = input["Object"]["Receiving"]
        result.kind = .receiving
        result.objectID = object["objectId"].stringValue
        result.version = UInt64(object["version"].stringValue) ?? 0
        result.digest = object["digest"].stringValue
    }
    return result
}

private func mapSuiCommand(_ command: JSON) -> Sui_Rpc_V2_Command {
    var result = Sui_Rpc_V2_Command()

    if (command["MoveCall"].exists()) {
        let c = command["MoveCall"]
        result.moveCall = Sui_Rpc_V2_MoveCall.with {
            $0.package = c["package"].stringValue
            $0.module = c["module"].stringValue
            $0.function = c["function"].stringValue
            $0.typeArguments = c["typeArguments"].arrayValue.map { $0.stringValue }
            $0.arguments = c["arguments"].arrayValue.map { mapSuiArgument($0) }
        }

    } else if (command["TransferObjects"].exists()) {
        let c = command["TransferObjects"]
        result.transferObjects = Sui_Rpc_V2_TransferObjects.with {
            $0.address = mapSuiArgument(c["address"])
            $0.objects = c["objects"].arrayValue.map { mapSuiArgument($0) }
        }

    } else if (command["SplitCoins"].exists()) {
        let c = command["SplitCoins"]
        result.splitCoins = Sui_Rpc_V2_SplitCoins.with {
            $0.coin = mapSuiArgument(c["coin"])
            $0.amounts = c["amounts"].arrayValue.map { mapSuiArgument($0) }
        }

    } else if (command["MergeCoins"].exists()) {
        let c = command["MergeCoins"]
        result.mergeCoins = Sui_Rpc_V2_MergeCoins.with {
            $0.coin = mapSuiArgument(c["destination"])
            $0.coinsToMerge = c["sources"].arrayValue.map { mapSuiArgument($0) }
        }

    } else if (command["MakeMoveVec"].exists()) {
        let c = command["MakeMoveVec"]
        result.makeMoveVector = Sui_Rpc_V2_MakeMoveVector.with {
            if let elementType = c["type"].string { $0.elementType = elementType }
            $0.elements = c["elements"].arrayValue.map { mapSuiArgument($0) }
        }

    } else if (command["Publish"].exists()) {
        let c = command["Publish"]
        result.publish = Sui_Rpc_V2_Publish.with {
            $0.modules = c["modules"].arrayValue.compactMap { Data(base64Encoded: $0.stringValue) }
            $0.dependencies = c["dependencies"].arrayValue.map { $0.stringValue }
        }

    } else if (command["Upgrade"].exists()) {
        let c = command["Upgrade"]
        result.upgrade = Sui_Rpc_V2_Upgrade.with {
            $0.package = c["package"].stringValue
            $0.ticket = mapSuiArgument(c["ticket"])
            $0.modules = c["modules"].arrayValue.compactMap { Data(base64Encoded: $0.stringValue) }
            $0.dependencies = c["dependencies"].arrayValue.map { $0.stringValue }
        }
    }
    return result
}

private func mapSuiArgument(_ argument: JSON) -> Sui_Rpc_V2_Argument {
    var result = Sui_Rpc_V2_Argument()

    if (argument["GasCoin"].exists()) {
        result.kind = .gas

    } else if (argument["Input"].exists()) {
        result.kind = .input
        result.input = argument["Input"].uInt32Value

    } else if (argument["Result"].exists()) {
        result.kind = .result
        result.result = argument["Result"].uInt32Value

    } else if (argument["NestedResult"].exists()) {
        let pair = argument["NestedResult"].arrayValue
        result.kind = .result
        result.result = pair.first?.uInt32Value ?? 0
        result.subresult = pair.count > 1 ? pair[1].uInt32Value : 0
    }
    return result
}
