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
    
    self.healthStore = [[HKHealthStore alloc]init];
    
//    设置需要获取的权限
    HKObjectType *stepCount = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
//     HKQuantityType Identifiers-主要体征- Vitals
    HKObjectType *heartRate = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKObjectType *bloodPressure1 = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];//收缩压
    HKObjectType *bloodPressure2 = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];//舒张压
    HKObjectType *temprature = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];//体温
     HKObjectType *breath = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierRespiratoryRate];//呼吸速率
    
//  HKCategoryType Identifiers- 睡眠状况 - 生殖健康等
    HKObjectType *sleep = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];//睡眠分析
    
    NSSet *healthSet = [NSSet setWithObjects:heartRate,bloodPressure1,bloodPressure2,temprature,breath,sleep,stepCount, nil];
    
//  获取权限 ShareTypes:<share>写入数据权限 readTypes:<read>读取数据权限
    
    
    [self.healthStore requestAuthorizationToShareTypes:healthSet readTypes:healthSet completion:^(BOOL success, NSError * _Nullable error) {
        if (success)
        {
            NSLog(@"获取权限成功");
//            [self readStep];
//            [self readSleep];
//            [self share];
//            [self shareSleep];
            [self collect];
        }
        else
        {
            NSLog(@"%@",error);
        }
    }];

    
    
}
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
#pragma mark - 读取step
-(void)readStep
{
    //查询采样信息
    HKSampleType *sampleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    

    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    /*limit:HKObjectQueryNoLimit:表示没有查询限制 即 读出所有stepcount
     */
    HKSampleQuery *sampleQuery = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:nil limit:20 sortDescriptors:@[sortDescriptor] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        //打印查询结果
        NSLog(@"resultCount = %ld result = %@",results.count,results);
        
        //把结果装换成字符串类型
        HKQuantitySample *result = results[0];
        HKQuantity *quantity = result.quantity;
        NSString *stepStr = (NSString *)quantity;

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            //查询是在多线程中进行的，如果要对UI进行刷新，要回到主线程中
            NSLog(@"最新步数：%@",stepStr);
            

        }];
        
    }];
    
    //执行查询
    [self.healthStore executeQuery:sampleQuery];
   
}
#pragma mark - 写入step
- (void)share
{
    HKQuantityType *myStep = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    HKQuantity *newCount = [HKQuantity quantityWithUnit:[HKUnit countUnit] doubleValue:300.0];
    HKQuantitySample *stepSample = [HKQuantitySample quantitySampleWithType:myStep quantity:newCount startDate:[[NSDate date] dateByAddingTimeInterval:- 4*60*60 ] endDate:[[NSDate date] dateByAddingTimeInterval:-3*60*60 ]];
    [self.healthStore saveObject:stepSample withCompletion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@">>>>>>>>>>>");
        }
        else
        {
//            NSLog(@"&@",error);
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

    dateComponents.hour = 1;
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

                }else if ([source.name isEqualToString:@"healthKit_demo"]){
                    NSLog(@"%@ -- 走了%.f步",source.name, [[statistic sumQuantityForSource:source] doubleValueForUnit:[HKUnit countUnit]]);}
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

