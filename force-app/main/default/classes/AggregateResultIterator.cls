global class AggregateResultIterator implements Iterator<AggregateResult> {

    AggregateResult [] results {get; set;}
    Integer index {get; set;}

    global AggregateResultIterator(String query) {
        index = 0;
        results = Database.query(query);
    }

    global boolean hasNext(){
        return results != null && !results.isEmpty() && index < results.size();
    }

    global AggregateResult next(){
        return results[index++];
    }
}
