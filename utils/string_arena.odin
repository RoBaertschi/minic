package utils

import "core:mem"
import "core:strings"

// Maintains immutable strings
String_Arena :: struct {
    allocator: mem.Allocator,
    strings: [dynamic]string,
}

sa_init :: proc(sa: ^String_Arena, allocator := context.allocator) -> (err: mem.Allocator_Error) {
    sa.strings = make([dynamic]string) or_return
    sa.allocator = allocator

    return
}

// Wipes the whole arena and frees all memory, has to be reinitalized using sa_init to be used again
sa_free_all :: proc(sa: ^String_Arena) -> mem.Allocator_Error {
    for s in sa.strings {
        delete(s, sa.allocator) or_return
    }
    // A dynamic array manages the allocator by itself, so no need to pass the sa.allocator
    delete(sa.strings) or_return
    sa.strings = nil
    return nil
}


// Copy the string and allocate it here, also returns the new allocated slice
sa_clone_string :: proc(sa: ^String_Arena, original: string) -> (clone: string, err: mem.Allocator_Error) {
    clone = strings.clone(original, sa.allocator) or_return
    if _, err = append(&sa.strings, clone); err != nil {
        // We have a clone, but because we couldn't add it to the list of managed strings, we need to delete it
        delete(clone, sa.allocator)
    }
    return
}

sa_clone_and_delete_string :: proc(sa: ^String_Arena, original: string, original_allocator: mem.Allocator) -> (clone: string, err: mem.Allocator_Error) {
    defer delete(original)
    return sa_clone_string(sa, original)
}
