//
//  ABCountryViewController.m
//  Shoppinghook
//
//  Created on 02/04/2014.
//  
//

#import "ABCountryViewController.h"
#import "ABCountryService.h"

@interface ABCountryViewController (){
    
    NSArray *countries;
    NSMutableArray *allSectionIndices;
    UILocalizedIndexedCollation   *collation;
}

@end

@implementation ABCountryViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Select Your Country";
    countries = [[ABCountryService service] listOfCountries];
    
    allSectionIndices = (NSMutableArray *)[self partitionObjects:countries collationStringSelector:@selector(self)];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Sectioned Data

-(NSArray *)partitionObjects:(NSArray *)array collationStringSelector:(SEL)selector
{
    collation = [UILocalizedIndexedCollation currentCollation];
    NSInteger sectionCount = [[collation sectionTitles] count];
    NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    for (int i = 0; i < sectionCount; i++) {
        [unsortedSections addObject:[NSMutableArray array]];
    }
    
    for (id object in array) {
        NSInteger index = [collation sectionForObject:[object objectForKey:@"name"] collationStringSelector:selector];
        [[unsortedSections objectAtIndex:index] addObject:object];
    }
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    
    for (NSMutableArray *section in unsortedSections) {
        NSArray *sortedArray = [section sortedArrayUsingDescriptors:sortDescriptors];
        [sections addObject:sortedArray];
    }
    
    return sections;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[allSectionIndices objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[collation sectionTitles] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [collation sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [collation sectionForSectionIndexTitleAtIndex:index];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    BOOL showSection = [[allSectionIndices objectAtIndex:section] count]!= 0;
    //only show the section title if there are rows in the section
    return (showSection) ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"country"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"country"];
    }
    
    NSArray *contactsInSection = [allSectionIndices objectAtIndex:indexPath.section];
    NSDictionary *country  = [contactsInSection objectAtIndex:indexPath.row];
    
    //NSDictionary *country = countries[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)",country[NAME],country[CODE]];
    cell.detailTextLabel.text = country[DIAL_CODE];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *contactsInSection = [allSectionIndices objectAtIndex:indexPath.section];
    NSDictionary *country  = [contactsInSection objectAtIndex:indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(didSelectedTheCountry:)]) {
        //NSDictionary *country = countries[indexPath.row];
        [self.delegate didSelectedTheCountry:country];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
