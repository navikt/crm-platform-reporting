global class AggregateResultIterable implements Iterable<AggregateResult>{
    private String query;

    global AggregateResultIterable(String soql) {
        query = soql;
    }

    global Iterator<AggregateResult> Iterator(){
        return new AggregateResultIterator(query);
    }
}
