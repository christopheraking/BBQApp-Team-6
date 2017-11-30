//
//  YLPClient+Search.h
//  Pods
//
//
//

#import "YLPClient.h"
#import "YLPSortType.h"

@class YLPCoordinate;
@class YLPQuery;
@class YLPSearch;

NS_ASSUME_NONNULL_BEGIN

typedef void(^YLPSearchCompletionHandler)(YLPSearch *_Nullable search, NSError *_Nullable error);

@interface YLPClient (Search)

- (void)searchWithQuery:(YLPQuery *)query
      completionHandler:(YLPSearchCompletionHandler)completionHandler;

- (void)searchWithLocation:(NSString *)location
                      term:(nullable NSString *)term
                     limit:(NSUInteger)limit
                    offset:(NSUInteger)offset
            categoryFilter:(NSArray<NSString *>*)categoryFilter
                      sort:(YLPSortType)sort
         completionHandler:(YLPSearchCompletionHandler)completionHandler;

- (void)searchWithLocation:(NSString *)location
         completionHandler:(YLPSearchCompletionHandler)completionHandler;

- (void)searchWithCoordinate:(YLPCoordinate *)coordinate
                        term:(nullable NSString *)term
                       limit:(NSUInteger)limit
                      offset:(NSUInteger)offset
              categoryFilter:(NSArray<NSString *>*)categoryFilter
                        sort:(YLPSortType)sort
           completionHandler:(YLPSearchCompletionHandler)completionHandler;

- (void)searchWithCoordinate:(YLPCoordinate *)coordinate
           completionHandler:(YLPSearchCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
