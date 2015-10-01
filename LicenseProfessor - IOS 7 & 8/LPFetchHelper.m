//
//  LPFetchHelper.m
//  licenseProfessorMockUp
//
//  Created by Kyle Ju on 2015-01-23.
//  Copyright (c) 2015 Kenny Park. All rights reserved.
//

#import "LPFetchHelper.h"

@implementation LPFetchHelper

+ (NSInteger) specialExamType{
    
    
    NSString *stateOfUser = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_STATE];
    NSString *userMaterial = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_STUDY_MATERIAL];
    if ([userMaterial isEqualToString:@"SalesAgent"]){
        
        NSArray * ASIArray = @[@"Alaska", @"Arizona", @"Arkansas", @"Delaware", @"Florida", @"Idaho", @"Indiana",@"Kansas",@"Kentucky", @"Maine",@"Rhode Island", @"Utah", @"Washington", @"Wisconsin", @"Washington, D.C."];
        
        NSArray * AMPArray = @[@"Alabama", @"Georgia", @"Illinois", @"Missouri", @"Montana", @"Nebraska", @"New Hampshire", @"North Dakota", @"Wyoming", @"South Dakota"];
        
        NSArray * PSIArray = @[@"Colorado", @"Connecticut", @"Hawaii", @"Iowa",@"Louisiana", @"Massachusetts", @"Maryland",@"Michigan", @"Minnesota", @"New Jersey", @"New Mexico", @"Nevada", @"North Carolina", @"Ohio", @"Pennsylvania", @"South Carolina", @"Tennessee", @"Texas", @"Vermont", @"Virginia"];
        
        NSMutableSet * ASISet = [NSMutableSet setWithArray:ASIArray];
        NSMutableSet * AMPSet = [NSMutableSet setWithArray:AMPArray];
        NSMutableSet * PSISet = [NSMutableSet setWithArray:PSIArray];
        
        if ([ASISet containsObject:stateOfUser]) return 1;
        else if ([AMPSet containsObject:stateOfUser]) return 2;
        else if ([PSISet containsObject:stateOfUser]) return 3;
        else return -1;
    }
    else return -1;
}





+ (NSMutableArray*)fetchRandomQuizByType:(NSString *)quizType andQuestionQuantity:(NSInteger)questionQuantity {
    NSString *stateOfUser = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_STATE];
    NSString *userMaterial = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_STUDY_MATERIAL];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Question"];
    if ( [quizType isEqualToString:@"General"]) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"((examState == %@) OR (examState == %@)) AND (materialChosen == %@)", @"NULL", stateOfUser, userMaterial];
    } else if ([quizType isEqualToString:@"Math"]) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"((examState == %@) OR (examState == %@)) AND (materialChosen == %@) AND (math == 1)", @"NULL", stateOfUser, userMaterial];
    } else {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"((examState == %@) OR (examState == %@)) AND (materialChosen == %@) AND (definition == 1)", @"NULL", stateOfUser, userMaterial];
    }
    
    NSManagedObjectContext *context = [LPCoreDataHelper managedObjectContext];
    NSError *error = nil;

    int myEntityCount = (int) [context countForFetchRequest:fetchRequest error:&error];
    NSArray *myEntities = [context executeFetchRequest:fetchRequest error: &error];
    NSUInteger numberOfRandomSamples = questionQuantity;
    NSMutableSet *sampledEntities = [NSMutableSet setWithCapacity:numberOfRandomSamples];
    while (sampledEntities.count < numberOfRandomSamples) {
        // generates random integer between 0 and myEntityCount-1
        NSUInteger randomEntityIndex = arc4random_uniform(myEntityCount);
        [sampledEntities addObject:[myEntities objectAtIndex:randomEntityIndex]];
    }
    NSMutableArray *returnQuestions = [NSMutableArray arrayWithArray:[sampledEntities allObjects]];
    return returnQuestions;
}


+ (BOOL) isStateSpecificExist{
    NSString *stateOfUser = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_STATE];
    NSString *userMaterial = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_STUDY_MATERIAL];
    NSFetchRequest *stateSpecificFetch  = [NSFetchRequest fetchRequestWithEntityName:@"Exam"];
    stateSpecificFetch.predicate = [NSPredicate predicateWithFormat:@"(location == %@) AND (examMaterialChosen == %@)", stateOfUser, userMaterial];
    NSManagedObjectContext *context = [LPCoreDataHelper managedObjectContext];
    NSError *error = nil;
    int myEntityCount = (int) [context countForFetchRequest:stateSpecificFetch error:&error];
    
    return (myEntityCount != 0);
}

+ (NSMutableArray *)examFetchHelper:(NSString*)examType
{
    NSString *stateOfUser = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_STATE];
    NSString *userMaterial = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_STUDY_MATERIAL];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Exam"];
            NSString *stateTitle = [stateOfUser stringByAppendingString:@" Specific Exam"];

    
    if ([examType isEqualToString:@"General"]) {
        if ([userMaterial isEqualToString:@"SalesAgent"]) fetchRequest.predicate = [NSPredicate predicateWithFormat: @"(examNo >= %i) AND (examNo <= %i)", 1, 10];
        else fetchRequest.predicate = [NSPredicate predicateWithFormat: @"(examNo >= %i) AND (examNo <= %i)", 15, 24];
    } else if ([examType isEqualToString:@"Definition"]) {
        if ([userMaterial isEqualToString:@"SalesAgent"]) fetchRequest.predicate = [NSPredicate predicateWithFormat: @"(examNo >= %i) AND (examNo <= %i)", 13, 14];
        else fetchRequest.predicate = [NSPredicate predicateWithFormat: @"(examNo >= %i) AND (examNo <= %i)", 27, 28];
    } else if ([examType isEqualToString:@"Math"]) {
        if ([userMaterial isEqualToString:@"SalesAgent"]) fetchRequest.predicate = [NSPredicate predicateWithFormat: @"(examNo >= %i) AND (examNo <= %i)", 11, 12];
        else fetchRequest.predicate = [NSPredicate predicateWithFormat: @"(examNo >= %i) AND (examNo <= %i)", 25, 26];
    } else if ([examType isEqualToString:stateTitle]){
        // when kenny pased in specific, it will fetch stat specific exam.
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(location == %@) AND (examMaterialChosen == %@)", stateOfUser, userMaterial];
    }
    else{
        
        if ([userMaterial isEqualToString:@"SalesAgent"]){
            
            NSInteger specialExam = [self specialExamType];
            switch (specialExam) {
                case 1:
                    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(location == %@)", @"ASI"];
                    break;
                case 2:
                    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(location == %@)", @"AMP"];
                    break;
                case 3:
                    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(location == %@)", @"PSI"];
                    break;
                    
                default:
                    NSLog(@"This state doesn't have any ASI, AMP or PSI exam");
                    break;
            }
        }else{
            return nil;
        }
        // for AMP, ASI AND PSI
    }
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"examNo" ascending:YES]];
    NSManagedObjectContext *context = [LPCoreDataHelper managedObjectContext];
    NSError *error = nil;
    NSMutableArray *returnExams = [NSMutableArray arrayWithArray:[context executeFetchRequest:fetchRequest error: &error]];
    return returnExams;
}


+ (void)savedQuestionsFetchHelper:(NSInteger)questionNumber{
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Question"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"questionID == %i", questionNumber];
    NSManagedObjectContext *context = [LPCoreDataHelper managedObjectContext];
    NSError *error = nil;
    NSArray *fetchedSavedQuestions = [context executeFetchRequest:fetchRequest error: &error];
    for (Question *eachQuestion in fetchedSavedQuestions){
        if (!eachQuestion.isSaved) eachQuestion.isSaved = YES;
    }
    [LPCoreDataHelper saveContext];
}

+ (Exam *)incompleteExamFetcher:(NSString*)examTitle {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Exam"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(title == %@)", examTitle];
    NSManagedObjectContext *context = [LPCoreDataHelper managedObjectContext];
    NSError *error = nil;
    NSMutableArray *returnExams = [NSMutableArray arrayWithArray:[context executeFetchRequest:fetchRequest error: &error]];
    Exam *returnExam = returnExams[0];
    return returnExam;
}







@end
