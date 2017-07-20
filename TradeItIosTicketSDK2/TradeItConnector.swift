public extension TradeItConnector {
    func sendReturnJSON(
        _ request: URLRequest,
        withCompletionBlock completionBlock: @escaping (TradeItResult, String) -> Void
    ) {
        self.sendEMSRequestReturnJSON(request, withCompletionBlock: completionBlock)
    }

    func send<T: TradeItResult>(
        _ request: URLRequest,
        targetClassType: T.Type,
        withCompletionBlock completionBlock: @escaping (TradeItResult?) -> Void
    ) {
        self.sendEMSRequestReturnJSON(request) { result, json in
            if result.status != "ERROR" { // Try to cast to desired resultClass
                completionBlock(TradeItResultTransformer.transform(targetClassType: targetClassType, json: json))
            } else {
                completionBlock(result) // Error case
            }
        }
    }

    private func sendEMSRequestReturnJSON(
        _ request: URLRequest,
        withCompletionBlock completionBlock: @escaping (TradeItResult, String) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let session = URLSession.shared
            session.dataTask(with: request, completionHandler: { data, response, error in
                if let data = data,
                    let json = String(data: data, encoding: .utf8),
                    let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 {
                    var result = TradeItResultTransformer.transform(targetClassType: TradeItResult.self, json: json)

                    if result?.status == "ERROR" { // Server sent an ERROR response so try create a TradeItErrorResult
                        let errorResult = TradeItResultTransformer.transform(targetClassType: TradeItErrorResult.self, json: json)
                        result = errorResult
                    }

                    let finalResult = result ?? TradeItErrorResult.error(withSystemMessage: "Server returned non TradeItResult")

                    DispatchQueue.main.async {
                        completionBlock(finalResult, json)
                    }
                } else {
                    // TODO: Figure out what to do here?
                    completionBlock(TradeItErrorResult.error(withSystemMessage: "Data Error"), "{}")
                }
            }).resume()
        }
    }
}

//
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
//        NSURLSession *session = [NSURLSession sharedSession];
//        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//            if ((data == nil) || ([httpResponse statusCode] != 200)) {
//            //error occured
//            NSLog(@"ERROR from EMS server response=%@ error=%@", response, error);
//            TradeItErrorResult *errorResult = [TradeItErrorResult errorWithSystemMessage:@"error sending request to ems server"];
//            dispatch_async(dispatch_get_main_queue(), ^(void) {
//            completionBlock(errorResult, nil);
//            });
//            return;
//            }
//
//            NSMutableString *jsonResponse = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//
//            TradeItResult *result = [TradeItRequestResultFactory buildResult:[TradeItResult alloc] jsonString:jsonResponse];
//
//            // TODO: Fix this up. Parses multiple times unnecessarily.
//            if (![result.status isEqualToString:@"ERROR"]) {
//            result = [TradeItRequestResultFactory buildResult:[ResultClass alloc] jsonString:jsonResponse];
//            } else {
//            result = [TradeItRequestResultFactory buildResult:[TradeItErrorResult alloc] jsonString:jsonResponse];
//            }
//
//            //            NSLog(@"----------Response %@----------", [[request URL] absoluteString]);
//            //            NSLog(jsonResponse);
//            dispatch_async(dispatch_get_main_queue(), ^(void) {
//            completionBlock(result, jsonResponse);
//            });
//            }] resume];
//        });
//}
