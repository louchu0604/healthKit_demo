//
//  ViewController.m
//  healthKit_demo
//
//  Created by user on 16/6/29.
//  Copyright © 2016年 Cy Lou. All rights reserved.
//

#import "ViewController.h"
#import <HealthKit/HealthKit.h>

@interface ViewController ()

@property (nonatomic,strong) HKHealthStore      *healthStore;

@end

@implementation ViewController

#pragma mark - 获取健康数据的权限暂时写在这里 最好写在APPDelegate中

- (void)viewDidLoad {
    [super viewDidLoad];
    [self request_healthKit];

    // Do any additional setup after loading the view, typically from a nib.
}

-(void)request_healthKit
{
    if (![HKHealthStore isHealthDataAvailable]) {
        NSLog(@"设备不支持healthKit");
    }
    
//   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=HEALTH/aaaa"]];
    
    self.healthStore = [[HKHealthStore alloc]init];
    
//    设置需要获取的权限
  
//     HKQuantityType Identifiers-主要体征- Vitals
    HKObjectType *heartRate = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
   
   
     HKObjectType *breath = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierRespiratoryRate];//呼吸速率
    
//  HKCategoryType Identifiers- 睡眠状况 - 生殖健康等
    HKObjectType *sleep = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];//睡眠分析
    
    NSSet *healthSet = [NSSet setWithObjects:heartRate,breath,sleep, nil];

    //  获取权限 ShareTypes:<share>写入数据权限 readTypes:<read>读取数据权限
    
    
    [self.healthStore requestAuthorizationToShareTypes:healthSet readTypes:healthSet completion:^(BOOL success, NSError * _Nullable error) {
        
        if (success)
        {
                        NSLog(@"获取权限成功");
            [self shareHeartRate];
//            [self shareRespiratory];
//            [self shareSleep];
//           
            
            
//            [self readSleep];
            [self readHeartRate];
//            [self readRespiratory];
        }
        else
        {
            NSLog(@"%@",error);
        }
    }];

}
/*
 
 #pragma mark -只查询今天的
 - (void)queryToday
 {
 HKQuantityType *todayType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
 NSTimeInterval secondsPerDay = 24 * 60 * 60;
 HKStatisticsOptions sum = HKStatisticsOptionCumulativeSum;
 NSDate *date1 = [NSDate date];
 NSDate *date2 = [date1 dateByAddingTimeInterval: -secondsPerDay];
 
 NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:date2 endDate:date1 options:HKQueryOptionStrictStartDate];
 HKStatisticsQuery *queryToday = [[HKStatisticsQuery alloc]initWithQuantityType:todayType quantitySamplePredicate:predicate options:sum completionHandler:^(HKStatisticsQuery * _Nonnull query, HKStatistics * _Nullable result, NSError * _Nullable error) {
 HKQuantity *quantity = [result sumQuantity];
 NSLog(@"今天走了%.1f",[quantity doubleValueForUnit:[HKUnit countUnit]]);
 }];
 [self.healthStore executeQuery:queryToday];
 }

 */

#pragma mark - 读取sleep
-(void)readSleep
{
     HKSampleType *sampleType = [HKCategoryType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
     NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    HKSampleQuery *sleepSample = [[HKSampleQuery alloc]initWithSampleType:sampleType predicate:nil limit:HKObjectQueryNoLimit sortDescriptors:@[sortDescriptor] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
       NSLog(@"resultCount = %ld result = %@",results.count,results);
    }];
     [self.healthStore executeQuery:sleepSample];
}
#pragma mark - 读取呼吸速率
-(void)readRespiratory
{
    HKSampleType *respiratory = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierRespiratoryRate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    HKSampleQuery *sampleQuery = [[HKSampleQuery alloc]initWithSampleType:respiratory predicate:nil limit:20 sortDescriptors:@[sortDescriptor] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
         NSLog(@"resultCount = %ld result = %@",results.count,results);
    }];
    [self.healthStore executeQuery:sampleQuery];
}
#pragma mark - 写入呼吸速率
-(void)shareRespiratory
{
    HKQuantityType *respiratory = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierRespiratoryRate];
    HKQuantity *respiratoryCount = [HKQuantity quantityWithUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] doubleValue:26];
    HKQuantitySample *sample = [HKQuantitySample quantitySampleWithType:respiratory quantity:respiratoryCount startDate:[[NSDate date] dateByAddingTimeInterval:- 8*60*60 ] endDate:[[NSDate date] dateByAddingTimeInterval:-1*60*60 ]];
    [self.healthStore saveObject:sample withCompletion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"respiratory>>>>>>>");
        }
        else
        {
            
        }
    }];
}

#pragma mark - 读取心率
- (void)readHeartRate
{
    HKSampleType *heartRate = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    HKSampleQuery  *sampleQuery = [[HKSampleQuery alloc]initWithSampleType:heartRate predicate:nil limit:20 sortDescriptors:@[sortDescriptor] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        NSLog(@"resultCount = %ld result = %@",results.count,results);
//遍历的时候选择性删除   for (HKObject *object in results)
               //        全部删除
//       [self.healthStore deleteObjects:results withCompletion:^(BOOL success, NSError * _Nullable error) {
//           if (success) {
//               NSLog(@"delete>>>>>>>>>>");
//           }
//       }];
    }];
    [self.healthStore executeQuery:sampleQuery];
}
#pragma mark - 写入心率
- (void)shareHeartRate
{
    
    NSString *str = @"2016/06/20 20:54:00";
     NSString *str1 = @"2016/06/20 20:55:00";
     NSString *str2 = @"2016/06/20 20:56:00";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date= [dateFormatter dateFromString:str];
    NSDate *date1= [dateFormatter dateFromString:str1];
    NSDate *date2= [dateFormatter dateFromString:str2];
    HKQuantityType *heartRate = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
   
    HKQuantity *heartRates = [HKQuantity quantityWithUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] doubleValue:68];
    
//    HKQuantitySample *heartSample = [HKQuantitySample quantitySampleWithType:heartRate quantity:heartRates startDate:[[NSDate date] dateByAddingTimeInterval:- 6*60*60 ] endDate:[[NSDate date] dateByAddingTimeInterval:-5*60*60 ]];
    HKQuantitySample *heartSample = [HKQuantitySample quantitySampleWithType:heartRate quantity:heartRates startDate:date endDate:date1];
    
    [self.healthStore saveObject:heartSample withCompletion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            
            NSLog(@"heartRate>>>startDate%@>>>>endDate%@>>>>",heartSample.startDate,heartSample.endDate);
        }
        else
        {
            
        }
    }];
    
}

#pragma mark - 写入sleep
- (void)shareSleep
{
    HKCategoryType *mySleep = [HKCategoryType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];

/*
 
value:1表示的是睡眠时间 value:0 表示的是在床休息 睡眠分析只能储存这两个值
 详细情况：https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HealthKit_Constants/index.html#//apple_ref/c/tdef/HKCategoryValueSleepAnalysis
 
 */
    HKCategorySample *sleep = [HKCategorySample categorySampleWithType:mySleep value:0 startDate:[[NSDate date]  dateByAddingTimeInterval:- 4*60*60 ] endDate:[NSDate date]];
    
    [self.healthStore saveObject:sleep withCompletion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
           
            NSLog(@">>>>>>>>>>>");
        }
        else
        {
            //            NSLog(@"&@",error);
        }
    }];
}
#pragma mark - 采集、统计数据
- (void)collect
{
       
//    系统提供的统计数据只只试用于HKQuantityType，其他类型需要我们自己统计
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
//    dateComponents.day = 1;

    dateComponents.hour = 2;
//    dateComponents.month = 1;

    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *date1 = [NSDate date];
    NSDate *date2 = [date1 dateByAddingTimeInterval: -secondsPerDay];
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:date2 endDate:date1 options:HKQueryOptionStrictStartDate];
    
//    quantitySamplePredicate:设定采样时间
    HKStatisticsCollectionQuery *collectionQuery = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType quantitySamplePredicate:predicate options: HKStatisticsOptionCumulativeSum | HKStatisticsOptionSeparateBySource anchorDate:[[NSDate date]dateByAddingTimeInterval:-secondsPerDay ] intervalComponents:dateComponents];
    collectionQuery.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection * __nullable result, NSError * __nullable error) {
        for (HKStatistics *statistic in result.statistics) {
//            NSLog(@"%@ 至 %@", statistic.startDate, statistic.endDate);
            for (HKSource *source in statistic.sources) {
                if ([source.name isEqualToString:[UIDevice currentDevice].name]) {
//                    NSLog(@"%@ -- 走了%f步",source, [[statistic sumQuantityForSource:source] doubleValueForUnit:[HKUnit countUnit]]);
                    NSLog(@"%@至%@%@ -- 走了%.f步",statistic.startDate, statistic.endDate,source.name, [[statistic sumQuantityForSource:source] doubleValueForUnit:[HKUnit countUnit]]);

                }else if ([source.name isEqualToString:@"healthKit_demo"]){
//                    NSLog(@"%@ -- 走了%.f步",source.name, [[statistic sumQuantityForSource:source] doubleValueForUnit:[HKUnit countUnit]]);
                }
            }
        }
    };
    

    [self.healthStore executeQuery:collectionQuery];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

