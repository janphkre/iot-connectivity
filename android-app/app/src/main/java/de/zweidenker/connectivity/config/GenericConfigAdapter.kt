package de.zweidenker.connectivity.config

import android.support.annotation.LayoutRes
import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import de.zweidenker.connectivity.R

class GenericConfigAdapter<T>(
    @LayoutRes private val itemLayout: Int,
    private val onClick: (T) -> Unit,
    private val bind: (T, View) -> Unit
) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    private var items: List<T> = emptyList()

    private enum class ViewTypes {
        Item,
        Header
    }

    fun setItems(newItems: List<T>) {
        synchronized(this) {
            items = newItems
            notifyDataSetChanged()
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when (viewType) {
            ViewTypes.Header.ordinal -> {
                val view = View(parent.context)
                view.layoutParams = ViewGroup.LayoutParams(1, 1)
                SpacerViewHolder(view, view)
            }
            else -> ItemViewHolder(parent)
        }
    }

    override fun getItemViewType(position: Int): Int {
        return when (position) {
            0 -> ViewTypes.Header
            else -> ViewTypes.Item
        }.ordinal
    }

    override fun getItemCount(): Int = items.size + 1

    override fun onBindViewHolder(viewHolder: RecyclerView.ViewHolder, position: Int) {
        when (position) {
            0 -> {
                (viewHolder as SpacerViewHolder).bind(viewHolder.itemView.resources.getDimensionPixelSize(R.dimen.list_header_margin))
            }
            else -> (viewHolder as GenericConfigAdapter<T>.ItemViewHolder).setContent(items[position - 1])
        }
    }

    override fun onViewRecycled(holder: RecyclerView.ViewHolder) {
        (holder as? GenericConfigAdapter<T>.ItemViewHolder)?.clear()
    }

    inner class ItemViewHolder(parent: ViewGroup) : RecyclerView.ViewHolder(LayoutInflater.from(parent.context).inflate(itemLayout, parent, false)) {
        private var item: T? = null

        init {
            itemView.setOnClickListener {
                item?.let(onClick)
            }
        }

        fun setContent(item: T) {
            this.item = item
            bind.invoke(item, itemView)
        }

        fun clear() {
            item = null
        }
    }

    private class SpacerViewHolder(itemView: View, private val spacingView: View) : RecyclerView.ViewHolder(itemView) {

        fun bind(size: Int) {
            spacingView.layoutParams = spacingView.layoutParams.apply {
                height = size
            }
        }
    }
}